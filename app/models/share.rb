# frozen_string_literal: true

# Model for a share permission of a Work to a User.
class Share < ApplicationRecord
  belongs_to :user
  belongs_to :work

  enum :permission, { view: 'view', edit: 'edit', deposit: 'deposit' }, default: :view
  validates :permission, presence: true
end
