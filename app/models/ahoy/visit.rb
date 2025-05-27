# frozen_string_literal: true

module Ahoy
  # An Ahoy visit model that tracks user visits
  class Visit < ApplicationRecord
    self.table_name = 'ahoy_visits'

    has_many :events, class_name: 'Ahoy::Event', dependent: :destroy
    belongs_to :user, optional: true
  end
end
