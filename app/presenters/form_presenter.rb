# frozen_string_literal: true

# Base class for all form presenters
class FormPresenter < SimpleDelegator
  include ActionView::Helpers::UrlHelper
  include LinkHelper

  def initialize(form:, version_status:)
    # By default, everything delegates to the form object
    @version_status = version_status
    super(form)
  end

  attr_reader :version_status

  delegate :discardable?, :editable?, :status_message, :first_draft?, :accessioning?, :first_version?,
           to: :version_status

  def related_links
    return 'None provided' if related_links_attributes.blank?

    related_links_attributes.filter_map do |related_link|
      next if related_link.url.blank?

      link_to_new_tab(related_link.text || related_link.url, related_link.url)
    end
  end

  def user_display(user)
    "#{user.name} (#{user.sunetid})"
  end
end
