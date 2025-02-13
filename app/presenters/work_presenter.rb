# frozen_string_literal: true

# Presents a work
class WorkPresenter < FormPresenter
  def initialize(work:, work_form:, version_status:)
    @work = work
    super(form: work_form, version_status:)
  end

  attr_reader :work, :version_status

  def purl_link
    # No druid yet, so there's no PURL link yet either. Work is likely still depositing.
    return if druid.blank?

    link_to(nil, Sdr::Purl.from_druid(druid:))
  end

  def collection_link
    link_to(collection.title, Rails.application.routes.url_helpers.collection_path(druid: collection.druid))
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

  def related_works
    related_works_attributes.map(&:to_s)
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
    case doi_option
    when 'yes'
      'A DOI will be assigned.'
    when 'no'
      'A DOI will not be assigned.'
    else
      doi_link
    end
  end

  def doi_link
    link_to(nil, Doi.url(druid:))
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

  private

  delegate :collection, :created_at, :user, :review_state, to: :work

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
end
