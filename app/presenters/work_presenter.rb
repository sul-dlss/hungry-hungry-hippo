# frozen_string_literal: true

# Presents a work
class WorkPresenter < ApplicationPresenter
  def initialize(work:, work_form:, version_status:)
    @work = work
    @work_form = work_form
    @version_status = version_status
    super()
  end

  attr_reader :work, :work_form, :version_status

  delegate :abstract, :authors, :citation, :title, :version, :work_type, to: :work_form
  delegate :druid, to: :work
  delegate :discardable?, :editable?, :status_message, to: :version_status

  def purl_link
    # No druid yet, so there's no PURL link yet either. Work is likely still depositing.
    return if druid.blank?

    link_to(nil, Sdr::Purl.from_druid(druid:))
  end

  def contact_emails
    contact_emails_attributes.map(&:email).join(', ')
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

  def related_links
    related_links_attributes.filter_map do |related_link|
      next if related_link.url.blank?

      link_to(related_link.text || related_link.url, related_link.url)
    end
  end

  def license_label
    return unless license

    WorkForm.licenses.find { |_, v| v['uri'] == license }.first
  end

  def publication_date
    work_form.publication_date.to_s
  end

  private

  delegate :collection, :created_at, :user, to: :work
  delegate :contact_emails_attributes, :keywords_attributes, :license, :other_work_subtype,
           :related_links_attributes, :related_works_attributes, :work_subtypes, to: :work_form
end
