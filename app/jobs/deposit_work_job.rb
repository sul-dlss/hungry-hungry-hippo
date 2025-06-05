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
    @original_cocina_object = Sdr::Repository.find(druid: work_form.druid) if work_form.persisted?
    # Setting current user so that it will be available for notifications.
    Current.user = current_user

    update_globus_content if globus?

    # Add missing digests and mime types
    Contents::Analyzer.call(content:)

    # If new_cocina_object is null then persist not performed since not changed.
    new_cocina_object = perform_persist
    druid = work_form.druid || new_cocina_object.externalIdentifier

    work.update!(druid:)

    perform_stage(druid:)

    WorkModelSynchronizer.call(work:, cocina_object: mapped_cocina_object)

    update_terms_of_deposit!

    accession_or_persist_complete(druid:)

    work.request_review! if request_review?

    # Content isn't needed anymore
    content.destroy!
  end

  private

  attr_reader :work_form, :work, :status, :original_cocina_object

  def user_name
    Current.user.sunetid
  end

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

  def changed?
    # @changed can be false, so normal ||= won't work here
    return @changed if defined?(@changed)

    @changed = RoundtripSupport.changed?(cocina_object: mapped_cocina_object)
  end

  # rubocop:disable Metrics/AbcSize
  def perform_persist
    if !work_form.persisted?
      Sdr::Repository.register(cocina_object: cocina_object_for_persist, assign_doi:, user_name:)
    elsif changed?
      Sdr::Repository.open_if_needed(cocina_object: cocina_object_for_persist,
                                     version_description: work_form.whats_changing, status:,
                                     user_name:)
                     .then do |cocina_object|
        Sdr::Repository.update(cocina_object:, user_name:)
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def assign_doi # rubocop:disable Naming/PredicateMethod
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
    @accession ||= deposit? && (!work_form.persisted? || status&.open? || changed?)
  end

  def globus?
    @globus ||= content.content_files.exists?(file_type: 'globus')
  end

  def accession_or_persist_complete(druid:)
    if accession?
      work.accession!
      Sdr::Repository.accession(druid:, new_user_version: new_user_version?)
      # If a collection manager or reviewer has rejected a previous review, we need to approve the work again
      work.approve! if work.rejected_review?
    else
      work.deposit_persist_complete!
    end
  end

  def new_user_version?
    return true unless work_form.persisted?

    # return true if structural changed
    UserVersionChangeService.call(original_cocina_object:, new_cocina_object: mapped_cocina_object)
  end

  def update_globus_content
    rename_globus_path if !work_form.persisted? && new_globus_path_exists? && !work_globus_path_exists?
    remove_globus_permissions
  rescue GlobusClient::AccessRuleNotFound
    # This exception normally occurs and should be ignored per https://github.com/sul-dlss/hungry-hungry-hippo/pull/1331/files#r2120804945
  end

  def new_globus_path_exists?
    GlobusClient.exists?(
      user_id: user.email_address,
      notify_email: false,
      path: GlobusSupport.user_path(user: Current.user, with_uploads_directory: true)
    )
  end

  def work_globus_path_exists?
    GlobusClient.exists?(
      user_id: user.email_address,
      notify_email: false,
      path: GlobusSupport.work_path(work:)
    )
  end

  def rename_globus_path
    GlobusClient.rename(
      new_path: GlobusSupport.work_path(work:, with_uploads_directory: true),
      user_id: user.email_address,
      notify_email: false,
      path: GlobusSupport.user_path(user: Current.user, with_uploads_directory: true)
    )
  end

  def remove_globus_permissions
    GlobusClient.delete_access_rule(
      user_id: user.email_address,
      notify_email: false,
      path: GlobusSupport.work_path(work:)
    )
  end

  def perform_stage(druid:)
    Contents::Stager.call(content:, druid:)
    return unless content.content_files.exists?(file_type: 'globus')

    Sdr::Event.create(druid:, type: 'h3_globus_staged', data: {})
  end
end
