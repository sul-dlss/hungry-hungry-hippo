# frozen_string_literal: true

module Emails
  # Component for inviting a user to subscribe to the newsletter.
  class NewsletterComponent < ApplicationComponent
    def call
      tag.p do
        "#{newsletter_link} for feature updates, tips, and related news.".html_safe # rubocop:disable Rails/OutputSafety
      end
    end

    def newsletter_link
      link_to 'Subscribe to the SDR newsletter', Settings.newsletter_url
    end
  end
end
