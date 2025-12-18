# frozen_string_literal: true

# Model representing a GitHub repository linked to a collection.
class GithubRepo < ApplicationRecord
  belongs_to :collection
  belongs_to :user
  belongs_to :work

  before_create :create_github_webhook
  before_destroy :delete_github_webhook

  def repo_url
    "#{Settings.github.base_repos_url}/#{repo_name}"
  end

  private

  # if github webhook does not exist and user has a connected account, create the webhook
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create_github_webhook
    Rails.logger.info "Creating webhook for repo: #{repo_name}, user: #{user.id}"

    unless user.github_connected?
      Rails.logger.error "User #{user.id} does not have a connected GitHub account"
      raise "No valid GitHub access token for user #{user.id}"
    end

    client = Octokit::Client.new(access_token: user.github_access_token)
    hook = client.create_hook(
      repo_name,
      'web',
      {
        url: Settings.github.webhook_url,
        content_type: 'json',
        secret: Settings.github.webhook_secret
      },
      {
        events: ['release'],
        active: true
      }
    )
    self.webhook_id = hook.id
    Rails.logger.info "Successfully created webhook with ID: #{hook.id}"
  rescue Octokit::Error => e
    Rails.logger.error "Octokit error creating webhook: #{e.message}"
    raise
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # if github webhook exists and user has a connected account, delete the webhook
  def delete_github_webhook
    raise "No valid GitHub access token for user #{user.id}" unless user.github_connected?

    client = Octokit::Client.new(access_token: user.github_access_token)
    client.remove_hook(
      repo_name,
      webhook_id
    )
  end
end
