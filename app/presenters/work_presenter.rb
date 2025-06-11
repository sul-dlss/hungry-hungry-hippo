# frozen_string_literal: true

# Presents a work
class WorkPresenter < FormPresenter
  include ActionPolicy::Behaviour

  def initialize(work:, work_form:, version_status:, user_version: 1)
    @work = work
    @user_version = user_version
    super(form: work_form, version_status:)
  end

  attr_reader :work, :version_status, :user_version

  def purl_link
    # No druid yet, so there's no PURL link yet either. Work is likely still depositing.
    return if druid.blank?

    purl = Sdr::Purl.from_druid(druid:)

    persistent_links_clickable? ? link_to(nil, purl) : purl
  end

  def doi_link
    # No druid yet, so there's no DOI link yet either. Work is likely still depositing.
    return if druid.blank?

    doi = Doi.url(druid:)

    persistent_links_clickable? ? link_to(nil, doi) : doi
  end

  # Returns DOI link if DOI is assigned, otherwise returns PURL link.
  def sharing_link
    work.doi_assigned? ? doi_link : purl_link
  end

  def collection_link
    link_to(collection.title, Rails.application.routes.url_helpers.collection_path(collection))
  end

  def deposited_at
    I18n.l(created_at, format: :long)
  end

  def depositor
    user.name
  end

  def keywords
    keywords_attributes.map(&:text).join(', ')
  end

  def all_work_subtypes
    (work_subtypes + [other_work_subtype]).compact.join(', ')
  end

  def license_label
    license_presenter.label
  end

  def publication_date
    super.to_s
  end

  def creation_date
    case create_date_type
    when 'single'
      create_date_single.to_s
    when 'range'
      "#{create_date_range_from} - #{create_date_range_to}"
    end
  end

  def access_label
    I18n.t("access.#{access}")
  end

  def release_date_label
    return 'Immediately' if release_option == 'immediate'

    I18n.l(release_date, format: :long)
  end

  def terms_of_use
    TermsOfUseSupport.full_statement(custom_rights_statement:)
  end

  def doi_value
    return 'A DOI will not be assigned.' if doi_option == 'no'

    doi_link
  end

  def status_message
    case review_state
    when 'pending_review'
      'Pending review'
    when 'rejected_review'
      'Returned'
    else
      super
    end
  end

  def number_of_files_in_deposit
    content_files_in_deposit.count
  end

  def size_of_deposit
    content_files_in_deposit.sum(&:size)
  end

  def editable?
    super && (!pending_review? || allowed_to?(:edit_pending_review?, work, context: { user: Current.user }))
  end

  def contact_emails
    (contact_emails_attributes.map(&:email) + [works_contact_email]).compact.join(', ')
  end

  private

  delegate :collection, :created_at, :user, :review_state, :pending_review?, to: :work

  def content_files_in_deposit
    ContentFile.where(content_id: work_form.content_id)
  end

  def license_presenter
    @license_presenter ||= LicensePresenter.new(work_form:, collection:)
  end

  def work_form
    # Get the object being delegated to (since this is a SimpleDelegator)
    __getobj__
  end

  def persistent_links_clickable?
    return false if version_status.is_a?(VersionStatus::NilStatus)
    return false if version_status.first_version? && (version_status.open? || version_status.accessioning?)

    true
  end
end
