# frozen_string_literal: true

module SubscriptionActions
  # Action that sends a review request to all reviewers and managers of a work's collection.
  class ReviewRequest
    def self.call(...)
      new(...).call
    end

    def initialize(work:)
      @work = work
    end

    def call
      work.collection.reviewers_and_managers.each do |user|
        ReviewsMailer.with(work:, user:).pending_email.deliver_later
      end
    end

    private

    attr_reader :work
  end
end
