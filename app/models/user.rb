# frozen_string_literal: true

# Model for a user.
class User < ApplicationRecord
  has_many :works, dependent: :destroy
end
