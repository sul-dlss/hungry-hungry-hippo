# frozen_string_literal: true

module Works
  module Show
    # Component providing a form for submitting a review.
    class ReviewComponent < ApplicationComponent
      def initialize(work:, review_form:)
        @work = work
        @review_form = review_form
        super()
      end

      attr_reader :review_form

      def render?
        @work.pending_review? && helpers.allowed_to?(:review?, @work)
      end
    end
  end
end
