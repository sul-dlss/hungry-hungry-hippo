# frozen_string_literal: true

# Model for a work.
# Note that this model does not contain any cocina data.
class Work < ApplicationRecord
  belongs_to :user
  belongs_to :collection

  state_machine :review_state, initial: :none_review do
    event :request_review do
      transition none_review: :pending_review
      transition rejected_review: :pending_review
    end

    before_transition any => :pending_review do |work|
      Notifier.publish(Notifier::REVIEW_REQUESTED, work:)
    end

    event :approve do
      transition pending_review: :none_review
    end

    before_transition pending_review: :none_review do |work|
      Notifier.publish(Notifier::REVIEW_APPROVED, work:)
    end

    event :reject do
      transition pending_review: :rejected_review
    end

    before_transition pending_review: :rejected_review do |work|
      Notifier.publish(Notifier::REVIEW_REJECTED, work:)
    end
  end

  def reject_with_reason!(reason:)
    self.review_rejected_reason = reason
    self.review_state_event = 'reject'
    save!
  end

  # deposit_job_started_at indicates that the job is queued or running.
  # User should be "waiting" until the job is completed.
  def deposit_job_started?
    deposit_job_started_at.present?
  end

  def deposit_job_finished?
    deposit_job_started_at.nil?
  end

  def doi_assigned?
    doi_assigned
  end
end
