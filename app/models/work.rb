# frozen_string_literal: true

# Model for a work.
# Note that this model does not contain any cocina data.
class Work < ApplicationRecord
  include DepositStateMachine

  belongs_to :user
  belongs_to :collection
  # This association isn't useful from this direction, so don't try to use it.
  has_many :content, dependent: :destroy

  state_machine :review_state, initial: :review_not_in_progress do
    event :request_review do
      transition review_not_in_progress: :pending_review
      transition rejected_review: :pending_review
    end

    before_transition any => :pending_review do |work|
      Notifier.publish(Notifier::REVIEW_REQUESTED, work:)
    end

    event :approve do
      transition pending_review: :review_not_in_progress
      transition rejected_review: :review_not_in_progress
    end

    before_transition pending_review: :review_not_in_progress do |work|
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

  def doi_assigned?
    doi_assigned
  end

  def first_version?
    version == 1
  end

  def bare_druid
    druid&.delete_prefix('druid:')
  end

  def to_param
    druid
  end
end
