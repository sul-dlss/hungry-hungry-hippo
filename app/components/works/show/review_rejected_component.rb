# frozen_string_literal: true

module Works
  module Show
    # Component for rendering an alert for a rejected review.
    class ReviewRejectedComponent < ApplicationComponent
      def initialize(work:)
        @work = work
        super()
      end

      delegate :review_rejected_reason, to: :@work

      def render?
        @work.rejected_review?
      end
    end
  end
end
