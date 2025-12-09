# frozen_string_literal: true

# Model representing a GitHub repository linked to a collection.
class CollectionGithubRepo < ApplicationRecord
  belongs_to :collection
end
