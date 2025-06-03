# frozen_string_literal: true

# Submits an SDR event when a review is rejected for a work.
class ReviewRejectedEventSubmitter
  def self.call(...)
    new(...).call
  end

  def initialize(work:, current_user:)
    @work = work
    @current_user = current_user
  end

  def call
    Sdr::Event.create(druid: work.druid, type: 'h3_review_returned', data:)
  end

  private

  attr_reader :work, :current_user

  def data
    { who: current_user.sunetid, comments: work.review_rejected_reason }
  end
end
