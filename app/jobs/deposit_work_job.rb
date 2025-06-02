# frozen_string_literal: true

# Performs a deposit or a work (without SDR API).
class DepositWorkJob < ApplicationJob
  # @param [WorkForm] work_form
  # @param [Work] work
  # @param [Boolean] deposit if true and review is not requested, deposit the work; otherwise, leave as draft
  # @param [Boolean] request_review if true, request view of the work
  # @param [User] current_user
  def perform(work_form:, work:, deposit:, request_review:, current_user:) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    @work_form = work_form
    @work = work
    @deposit = deposit
    @request_review = request_review
    @status = Sdr::Repository.status(druid: work_form.druid) if work_form.persisted?
    @current_user = current_user
    # Setting current user so that it will be available for notifications.
    Current.user = current_user

    update_globus_content if globus?

    # Add missing digests and mime types
    Contents::Analyzer.call(content:)

    # If new_cocina_object is null then persist not performed since not changed.
    new_cocina_object = perform_persist
    druid = work_form.druid || new_cocina_object.externalIdentifier

    work.update!(druid:)

    Contents::Stager.call(content:, druid:)

    WorkModelSynchronizer.call(work:, cocina_object: mapped_cocina_object)

    update_terms_of_deposit!

    accession_or_persist_complete(druid:)

    work.request_review! if request_review?

    # Content isn't needed anymore
    content.destroy!
  end

  private

  attr_reader :work_form, :work, :status, :current_user

  def content
    @content ||= Content.find(work_form.content_id)
  end

  def mapped_cocina_object
    @mapped_cocina_object ||= Cocina::WorkMapper.call(work_form:, content:, source_id: "h3:object-#{work.id}")
  end

  def mapped_cocina_object_with_update_deposit_publication_date
    updated_work_form = work_form.dup
    updated_work_form.deposit_publication_date = Time.zone.today
    Cocina::WorkMapper.call(work_form: updated_work_form, content:, source_id: "h3:object-#{work.id}")
  end

  def cocina_object_for_persist
    # When accessioning, update the deposit publication date to today.
    accession? ? mapped_cocina_object_with_update_deposit_publication_date : mapped_cocina_object
  end

  def perform_persist
    if !work_form.persisted?
      Sdr::Repository.register(cocina_object: cocina_object_for_persist, assign_doi:)
    elsif RoundtripSupport.changed?(cocina_object: mapped_cocina_object)
      Sdr::Repository.open_if_needed(cocina_object: cocina_object_for_persist,
                                     version_description: work_form.whats_changing, status:)
                     .then do |cocina_object|
        Sdr::Repository.update(cocina_object:)
      end
    end
  end

  def assign_doi
    work_form.doi_option == 'yes'
  end

  def update_terms_of_deposit!
    return if user.agree_to_terms?

    user.update!(agreed_to_terms_at: Time.zone.now)
  end

  def user
    work.user
  end

  # If request review, deposit will be saved, but not deposited until approved.
  def deposit?
    request_review? ? false : @deposit
  end

  def request_review?
    @request_review
  end

  def accession?
    # If a new cocina object, then accessionable.
    # If work already opened, then the work has changes and can be accessioned.
    @accession ||= deposit? && (!work_form.persisted? || status&.open?)
  end

  def globus?
    @globus ||= content.content_files.exists?(file_type: 'globus')
  end

  def endpoint_client_for(path)
    GlobusClient::Endpoint.new(user_id: user.email_address, path:, notify_email: false)
  end

  def accession_or_persist_complete(druid:)
    if accession?
      work.accession!
      Sdr::Repository.accession(druid:, user_name: current_user.sunetid)
      # If a collection manager or reviewer has rejected a previous review, we need to approve the work again
      work.approve! if work.rejected_review?
    else
      work.deposit_persist_complete!
    end
  end

  def update_globus_content # rubocop:disable Metrics/AbcSize
    new_endpoint_client = endpoint_client_for(GlobusSupport.new_path(user: current_user, with_uploads_directory: true))
    work_endpoint_client = endpoint_client_for(GlobusSupport.path(work:))
    # rename if not persisted and globus?
    if !work_form.persisted? && new_endpoint_client.exists? && !work_endpoint_client.exists?
      new_endpoint_client.rename(new_path: GlobusSupport.path(work:, with_uploads_directory: true))
    end
    # remove permissions
    work_endpoint_client.delete_access_rule
  rescue StandardError => e
    raise unless e.message.include?('Access rule not found')
  end
end
