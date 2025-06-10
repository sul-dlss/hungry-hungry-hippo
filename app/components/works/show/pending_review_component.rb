# frozen_string_literal: true

module Works
  module Show
    # Component for rendering an alert for a work pending review.
    class PendingReviewComponent < ApplicationComponent
      attr_reader :work_presenter

      def initialize(work_presenter:)
        @work_presenter = work_presenter
        super()
      end

      def render?
        work_presenter.pending_review?
      end
    end
  end
end
