# frozen_string_literal: true

# Model for a work.
# Note that this model does not contain any cocina data.
class Work < ApplicationRecord
  include DepositStateMachine

  belongs_to :user
  belongs_to :collection
  has_many :shares, dependent: :destroy
  has_many :share_users, through: :shares, source: :user
  # The association below isn't useful from this direction, so don't try to use it.
  # This is because the content model object is refreshed from cocina before it is
  # accessed (see the `set_content` method in the WorksController), which generates
  # a new content object reach time it is done.  We therefore can have many content
  # objects for a single work, only one of which is relevant.  It should be the
  # latest one, but there is no guarantee that is up to date unless it has just
  # been refreshed.
  has_many :content, dependent: :destroy

  state_machine :review_state, initial: :review_not_in_progress do
    event :request_review do
      transition review_not_in_progress: :pending_review
      transition rejected_review: :pending_review
    end

    before_transition any => :pending_review do |work|
      Notifier.publish(Notifier::REVIEW_REQUESTED, work:, current_user: Current.user)
    end

    event :approve do
      transition pending_review: :review_not_in_progress
      transition rejected_review: :review_not_in_progress
    end

    before_transition pending_review: :review_not_in_progress do |work|
      Notifier.publish(Notifier::REVIEW_APPROVED, work:, current_user: Current.user)
    end

    event :reject do
      transition pending_review: :rejected_review
    end

    before_transition pending_review: :rejected_review do |work|
      Notifier.publish(Notifier::REVIEW_REJECTED, work:, current_user: Current.user)
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
