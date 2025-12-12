# frozen_string_literal: true

# Model representing a GitHub repository linked to a collection.
class GithubRepo < ApplicationRecord
  belongs_to :collection
  belongs_to :user
end
