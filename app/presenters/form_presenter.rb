# frozen_string_literal: true

# Base class for all form presenters
class FormPresenter < SimpleDelegator
  include ActionView::Helpers::UrlHelper

  def initialize(form:, version_status:)
    # By default, everything delegates to the form object
    @version_status = version_status
    super(form)
  end

  attr_reader :version_status

  delegate :discardable?, :editable?, :status_message, to: :version_status

  def related_links
    return 'None provided' if related_links_attributes.blank?

    related_links_attributes.filter_map do |related_link|
      next if related_link.url.blank?

      link_to(related_link.text || related_link.url, related_link.url)
    end
  end

  def contact_emails
    contact_emails_attributes.map(&:email).join(', ')
  end
end
