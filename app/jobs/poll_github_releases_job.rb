# frozen_string_literal: true

# Job for polling GitHub releases for a given repository and creating GithubRelease records for any new releases found.
class PollGithubReleasesJob < ApplicationJob
  queue_as :github

  def perform(github_repository:)
    return unless github_repository.github_deposit_enabled

    GithubService.releases(github_repository.github_repository_id).each do |release|
      next if github_repository.github_releases.exists?(release_id: release.id)

      next if release.published_at < github_repository.created_at # Do not get releases published before repo was added

      github_repository.github_releases.create!(
        release_tag: release.tag,
        release_id: release.id,
        release_name: release.name,
        zip_url: release.zip_url,
        published_at: release.published_at
      )
    end
  end
end
