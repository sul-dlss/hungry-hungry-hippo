# frozen_string_literal: true

# Model for a user.
class User < ApplicationRecord
  has_many :works, dependent: :destroy
  has_many :collections, dependent: :destroy

  has_many :collection_managers, dependent: :destroy
  has_many :collection_depositors, dependent: :destroy
  has_many :collection_reviewers, dependent: :destroy
  has_many :manages, through: :collection_managers, source: :collection
  has_many :depositor_for, through: :collection_depositors, source: :collection
  has_many :reviewer_for, through: :collection_reviewers, source: :collection

  EMAIL_SUFFIX = '@stanford.edu'

  def sunetid
    email_address.delete_suffix(EMAIL_SUFFIX)
  end

  # Returns all collections that the user manages, deposits to, or reviews.
  def your_collections
    @your_collections ||= Collection.left_outer_joins(:managers, :depositors, :reviewers).where(managers: { id: }).or(
      Collection.left_outer_joins(:managers, :depositors, :reviewers).where(depositors: { id: })
    ).or(
      Collection.left_outer_joins(:managers, :depositors, :reviewers).where(reviewers: { id: })
    ).distinct
  end

  # Returns all works for collections that the user manages, deposits to, or reviews.
  def your_works
    @your_works ||= Work.where(collection: your_collections).or(Work.where(user: self))
  end

  def agree_to_terms?
    agreed_to_terms_at.present?
  end

  def your_pending_review_works
    @your_pending_review_works ||= Work.where(collection: reviewer_for + manages).with_review_state(:pending_review)
  end

  def roles_for(collection:)
    [].tap do |roles|
      roles << 'manager' if manages.include?(collection)
      roles << 'depositor' if depositor_for.include?(collection)
      roles << 'reviewer' if reviewer_for.include?(collection)
    end
  end

  def self.find_by_sunetid(sunetid:)
    find_by(email_address: "#{sunetid}#{EMAIL_SUFFIX}")
  end
end
