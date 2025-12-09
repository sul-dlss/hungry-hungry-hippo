# frozen_string_literal: true

module Collections
  # Controller to manage GitHub integrations for collections and linking of repos
  class GithubIntegrationsController < ApplicationController
    before_action :set_collection

    def index
      authorize! @collection, to: :manage?

      @linked_repos = @collection.collection_github_repos

      # if the user has not connected their GitHub account, prompt them to do so
      if current_user.github_access_token.blank?
        session[:return_to] = request.fullpath
        return
      end

      begin
        client = Octokit::Client.new(access_token: current_user.github_access_token)
        # Fetching all repos the user has access to. Pagination might be needed for users with many repos.
        @repos = client.repos(nil, type: 'public', sort: :updated, per_page: 100).map do |repo|
          [repo.full_name, repo.id]
        end
      rescue Octokit::Unauthorized
        @github_token_invalid = true
      end
    end

    def create
      authorize! @collection, to: :manage?

      client = Octokit::Client.new(access_token: current_user.github_access_token)
      repo_name = params[:github_repo_name] # This should be full_name e.g. "owner/repo"
      repo_id = params[:github_repo_id]

      # Create the webhook on GitHub
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

      @collection.collection_github_repos.create!(
        github_repo_id: repo_id,
        github_repo_name: repo_name,
        webhook_id: hook.id
      )
      flash[:success] = 'GitHub repository linked successfully.'
      redirect_to collection_github_integrations_path(@collection.druid)
    rescue Octokit::Error => e
      flash[:danger] = "Failed to link GitHub repository: #{e.message}"
      redirect_to collection_github_integrations_path(@collection.druid)
    end

    def destroy
      authorize! @collection, to: :manage?

      repo = @collection.collection_github_repos.find(params[:id])

      if repo.webhook_id
        client = Octokit::Client.new(access_token: current_user.github_access_token)
        begin
          client.remove_hook(
            repo.github_repo_name,
            repo.webhook_id
          )
        rescue Octokit::Error
          # Ignore if hook is already gone or user lost access
        end
      end

      repo.destroy
      flash[:success] = 'GitHub repository unlinked successfully.'
      redirect_to collection_github_integrations_path(@collection.druid)
    end

    private

    def set_collection
      @collection = Collection.find_by!(druid: params[:collection_druid])
    end
  end
end
