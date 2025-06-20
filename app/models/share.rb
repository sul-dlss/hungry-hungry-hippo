# frozen_string_literal: true

# Model for a share permission of a Work to a User.
class Share < ApplicationRecord
  VIEW_PERMISSION = 'view'
  VIEW_EDIT_PERMISSION = 'edit'
  VIEW_EDIT_DEPOSIT_PERMISSION = 'deposit'

  belongs_to :user
  belongs_to :work

  after_create -> { Notifier.publish(Notifier::SHARE_ADDED, share: self, work:) }

  enum :permission, { view: 'view', edit: 'edit', deposit: 'deposit' }, default: :view
  validates :permission, presence: true
end
