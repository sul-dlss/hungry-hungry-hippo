# frozen_string_literal: true

# Model for a user.
class User < ApplicationRecord
  has_many :works, dependent: :destroy
  has_many :collections, dependent: :destroy

  has_and_belongs_to_many :manages, class_name: 'Collection', join_table: 'managers'
  has_and_belongs_to_many :depositor_for, class_name: 'Collection', join_table: 'depositors'
  has_and_belongs_to_many :reviewer_for, class_name: 'Collection', join_table: 'reviewers'

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
