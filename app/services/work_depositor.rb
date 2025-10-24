# frozen_string_literal: true

# Performs a deposit or a work (without SDR API).
class WorkDepositor
  # @see #initialize
  def self.call(...)
    new(...).deposit
  end

  # @param [WorkForm] work_form
  # @param [Work] work
  # @param [Boolean] deposit if true and review is not requested, deposit the work; otherwise, leave as draft
  # @param [Boolean] request_review if true, request view of the work
  # @param [User] current_user
  def initialize(work_form:, work:, deposit:, request_review:, current_user:)
    @work_form = work_form
    @work = work
    @request_review = request_review
    # If review requested, the work will be saved, but will not be deposited until it is approved.
    @deposit = request_review ? false : deposit
    # Setting current user so that it will be available for notifications.
    Current.user = current_user
  end

  def deposit
    remove_globus_permissions!

    # Add missing digests and mime types
    Contents::Analyzer.call(content:)

    new_cocina_object = persist_to_repository

    druid = work_form.druid || new_cocina_object.externalIdentifier

    work.update!(druid:)

    perform_stage(druid:)

    WorkModelSynchronizer.call(work:, cocina_object: mapped_cocina_object)

    update_terms_of_deposit!

    if accession?
      work.accession!
      Sdr::Repository.accession(druid:, new_user_version: new_user_version?,
                                version_description: work_form.whats_changing)
      # If a collection manager or reviewer has rejected a previous review, we need to approve the work again
      work.approve! if work.rejected_review?
      update_last_deposited_at!
    else
      work.deposit_persist_complete!
    end

    work.request_review! if request_review?

    # Content isn't needed anymore
    content.destroy!
  end

  private

  attr_reader :work_form, :work

  def deposit?
    @deposit
  end

  def request_review?
    @request_review
  end

  def status
    @status ||= Sdr::Repository.status(druid: work_form.druid) if work_form.persisted?
  end

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

    original_cocina_object = Sdr::Repository.find(druid: work_form.druid)
    @changed = RoundtripSupport.changed?(cocina_object: mapped_cocina_object, original_cocina_object:)
  end

  def persist_to_repository
    if work_form.persisted?
      Sdr::Repository
        .open_if_needed(cocina_object: cocina_object_for_persist,
                        version_description: work_form.whats_changing, status:,
                        user_name:)
        .then do |cocina_object|
        Sdr::Repository.update(cocina_object:, user_name:, description: new_user_version? ? 'Files changed' : nil)
      end
    else
      Sdr::Repository.register(cocina_object: cocina_object_for_persist, assign_doi: assign_doi?, user_name:)
    end
  end

  def assign_doi?
    work_form.doi_option == 'yes'
  end

  def update_terms_of_deposit!
    return if user.agree_to_terms?

    user.update!(agreed_to_terms_at: Time.zone.now)
  end

  def user
    work.user
  end

  def accession?
    # If a new cocina object, then accessionable.
    # If work already opened, then the work has changes and can be accessioned.
    @accession ||= deposit? && (!work_form.persisted? || status&.open? || changed?)
  end

  def globus?
    @globus ||= content.content_files.exists?(file_type: 'globus')
  end

  def update_last_deposited_at!
    work.update!(last_deposited_at: Time.zone.now)
  end

  def new_user_version?
    # @new_user_version can be false, so normal ||= won't work here
    return @new_user_version if defined?(@new_user_version)

    return (@new_user_version = true) unless work_form.persisted?

    # return true if structural changed since last user version
    original_cocina_object = Sdr::Repository.find_latest_user_version(druid: work_form.druid)
    @new_user_version = UserVersionChangeService.call(original_cocina_object:, new_cocina_object: mapped_cocina_object)
  end

  def remove_globus_permissions!
    return unless globus?

    GlobusClient.delete_access_rule(
      user_id: user.email_address,
      notify_email: false,
      path: GlobusSupport.work_path(work:)
    )
  rescue GlobusClient::AccessRuleNotFound
    # This exception normally occurs and should be ignored per https://github.com/sul-dlss/hungry-hungry-hippo/pull/1331/files#r2120804945
  end

  def perform_stage(druid:)
    Contents::Stager.call(content:, druid:)
    return unless globus?

    Sdr::Event.create(druid:, type: 'h3_globus_staged', data: {})
  end
end
