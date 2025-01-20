# frozen_string_literal: true

module Emails
  # Component for providing contact info.
  class ContactComponent < ApplicationComponent
    def call
      tag.p do
        "If you have any questions, contact the SDR team at: #{contact_form_link}".html_safe # rubocop:disable Rails/OutputSafety
      end
    end

    def contact_form_link
      link_to nil, contact_form_url
    end
  end
end
