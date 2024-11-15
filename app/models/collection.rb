# frozen_string_literal: true

# Model for a collection.
# Note that this model does not contain any cocina data.
class Collection < ApplicationRecord
  belongs_to :user
  has_many :works, dependent: :destroy
end
