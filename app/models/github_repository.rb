# frozen_string_literal: true

# Model for a GitHub repository work
class GithubRepository < Work
  validates :github_repository_id, presence: true
  validates :github_repository_name, presence: true
end
