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

      # only render if the work is pending review and the current user is the depositor
      def render?
        work_presenter.pending_review? && work_presenter.user == Current.user
      end
    end
  end
end
