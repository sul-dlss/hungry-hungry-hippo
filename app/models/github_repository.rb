# frozen_string_literal: true

# Model for a GitHub repository work
class GithubRepository < Work
  has_many :github_releases, dependent: :destroy

  validates :github_repository_id, presence: true
  validates :github_repository_name, presence: true

  # Note that github_deposit_enabled is a nillable boolean.
  # Nil indicates that the user has not made a choice about whether to enable GitHub deposit.
  # Only a value of true indicates that GitHub deposit is enabled.
end
