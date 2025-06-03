# frozen_string_literal: true

# Submits an SDR event when a review is requested for a work.
class ReviewRequestedEventSubmitter
  def self.call(...)
    new(...).call
  end

  def initialize(work:, current_user:)
    @work = work
    @current_user = current_user
  end

  def call
    Sdr::Event.create(druid: work.druid, type: 'h3_review_requested', data: { who: current_user.sunetid })
  end

  private

  attr_reader :work, :current_user
end
