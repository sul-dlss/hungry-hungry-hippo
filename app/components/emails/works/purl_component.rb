# frozen_string_literal: true

module Emails
  module Works
    # Component for displaying the PURL for a work
    class PurlComponent < ApplicationComponent
      def initialize(work:)
        @work = work
        super()
      end

      def call
        tag.p do
          "The persistent URL (PURL) for this deposit is #{purl_link}. Please use this when citing your work.".html_safe # rubocop:disable Rails/OutputSafety
        end
      end

      def purl_link
        link_to nil, Sdr::Purl.from_druid(druid: @work.druid)
      end
    end
  end
end
