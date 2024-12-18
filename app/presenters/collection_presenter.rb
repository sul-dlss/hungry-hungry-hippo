# frozen_string_literal: true

# Presents a collection
class CollectionPresenter < ApplicationPresenter
  def initialize(collection:, collection_form:, version_status:)
    @collection = collection
    @collection_form = collection_form
    @version_status = version_status
    super()
  end

  attr_reader :collection, :collection_form, :version_status

  delegate :description, :title, to: :collection_form
  delegate :druid, to: :collection
  delegate :editable?, :status_message, to: :version_status

  def contact_emails
    contact_emails_attributes.map(&:email).join(', ')
  end

  def related_links
    related_links_attributes.filter_map do |related_link|
      next if related_link.url.blank?

      link_to(related_link.text || related_link.url, related_link.url)
    end
  end

  private

  delegate :contact_emails_attributes, :related_links_attributes, to: :collection_form
end
