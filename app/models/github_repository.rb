# frozen_string_literal: true

# Model for a GitHub repository work
class GithubRepository < Work
  has_many :github_releases, dependent: :destroy

  validates :github_repository_id, presence: true
  validates :github_repository_name, presence: true
end
