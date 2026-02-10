# frozen_string_literal: true

# Model for a GitHub release
class GithubRelease < ApplicationRecord
  belongs_to :github_repository, class_name: 'GithubRepository'

  enum :status, { queued: 'queued', started: 'started', completed: 'completed' }
end
