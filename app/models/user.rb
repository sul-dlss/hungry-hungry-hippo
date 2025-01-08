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
end
