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

  private

  delegate :collection, :created_at, :user, to: :work

  def license_presenter
    @license_presenter ||= LicensePresenter.new(work_form:, collection:)
  end

  def work_form
    # Get the object being delegated to (since this is a SimpleDelegator)
    __getobj__
  end
end
