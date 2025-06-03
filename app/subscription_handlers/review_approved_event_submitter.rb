# frozen_string_literal: true

# Submits an SDR event when a review is approved for a work.
class ReviewApprovedEventSubmitter
  def self.call(...)
    new(...).call
  end

  def initialize(work:, current_user:)
    @work = work
    @current_user = current_user
  end

  def call
    Sdr::Event.create(druid: work.druid, type: 'h3_review_approved', data: { who: current_user.sunetid })
  end

  private

  attr_reader :work, :current_user
end
