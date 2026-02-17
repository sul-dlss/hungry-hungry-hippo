# frozen_string_literal: true

# Job for polling GitHub releases for a given repository and creating GithubRelease records for any new releases found.
class PollGithubReleasesJob < ApplicationJob
  queue_as :github

  def perform(github_repository:, immediate_deposit: false)
    return unless github_repository.github_deposit_enabled

    new_github_release = nil
    Github::AppService.releases(github_repository.github_repository_id).each do |release|
      next if github_repository.github_releases.exists?(release_id: release.id)

      next if release.published_at < github_repository.created_at # Do not get releases published before repo was added

      new_github_release ||= new_github_release_for(github_repository:, release:)
    end

    start_deposit_release_job(github_release: new_github_release) if immediate_deposit
  end

  private

  def new_github_release_for(github_repository:, release:)
    github_repository.github_releases.create!(
      release_tag: release.tag,
      release_id: release.id,
      release_name: release.name,
      zip_url: release.zip_url,
      published_at: release.published_at
    )
  end

  def start_deposit_release_job(github_release:)
    return unless github_release

    DepositGithubReleaseJob.perform_later(github_release:, skip_publish_wait: true)
  end
end
