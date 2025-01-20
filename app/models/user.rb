# frozen_string_literal: true

# Model for a user.
class User < ApplicationRecord
  has_many :works, dependent: :destroy
  has_many :collections, dependent: :destroy

  has_many :collection_manager, dependent: :destroy
  has_many :collection_depositor, dependent: :destroy
  has_many :collection_reviewer, dependent: :destroy
  has_many :manages, through: :collection_manager, source: :collection
  has_many :depositor_for, through: :collection_depositor, source: :collection
  has_many :reviewer_for, through: :collection_reviewer, source: :collection

  EMAIL_SUFFIX = '@stanford.edu'

  def sunetid
    email_address.delete_suffix(EMAIL_SUFFIX)
  end

  # Returns all collections that the user manages, deposits to, or reviews.
  def your_collections
    Collection.left_outer_joins(:managers, :depositors, :reviewers).where(managers: { id: }).or(
      Collection.left_outer_joins(:managers, :depositors, :reviewers).where(depositors: { id: })
    ).or(
      Collection.left_outer_joins(:managers, :depositors, :reviewers).where(reviewers: { id: })
    ).distinct
  end

  # Returns all works for collections that the user manages, deposits to, or reviews.
  def your_works
    Work.where(collection: your_collections)
  end
end
