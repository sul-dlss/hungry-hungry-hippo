# frozen_string_literal: true

module Emails
  module Works
    # Component for displaying a message about a DOI being assigned to a work.
    class DoiComponent < ApplicationComponent
      def initialize(work:, work_presenter:)
        @work = work
        @work_presenter = work_presenter
        super()
      end

      def call
        tag.p do
          "Your work was assigned this DOI: #{@work_presenter.doi_link}".html_safe # rubocop:disable Rails/OutputSafety
        end
      end

      def render?
        @work.doi_assigned?
      end
    end
  end
end
