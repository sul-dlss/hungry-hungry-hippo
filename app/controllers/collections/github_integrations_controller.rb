# frozen_string_literal: true

module Collections
  # Controller to manage GitHub integrations for collections and linking of repos
  class GithubIntegrationsController < ApplicationController
    before_action :set_collection

    def index
      authorize! @collection, to: :manage?

      # if the user has not connected their GitHub account yet, redirect to the page that lets them connect their account
      unless current_user.github_connected?
        # store this page so we can redirect back here after auth is complete with github
        session[:return_to] = request.fullpath
        redirect_to github_integrations_path
      end

      # currently linked repos for this collection
      @linked_repos = @collection.github_repos.where(user: current_user)

      # Fetching all repos the user has access to. Pagination might be needed for users with many repos.
      # Repos can only be connected once to SDR for any collection and any user, so filter out already connected repos.
      client = Octokit::Client.new(access_token: current_user.github_access_token)
      @repos = client.repos(nil, type: 'public', sort: :updated, per_page: 100).filter_map do |repo|
        [repo.full_name, repo.id] unless GithubRepo.exists?(repo_name: repo.full_name)
      end
    end

    def create
      authorize! @collection, to: :manage?

      client = Octokit::Client.new(access_token: current_user.github_access_token)
      repo_name = params[:repo_name] # This should be full_name e.g. "owner/repo"
      repo_id = params[:repo_id]

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

      @collection.github_repos.create!(
        repo_id:,
        repo_name:,
        user: current_user,
        webhook_id: hook.id
      )
      flash[:success] = 'The GitHub repository has been successfully linked to this collection.'
      redirect_to collection_github_integrations_path(@collection.druid)
    rescue Octokit::Error => e
      flash[:danger] = "Failed to link GitHub repository: #{e.message}"
      redirect_to collection_github_integrations_path(@collection.druid)
    end

    def destroy
      authorize! @collection, to: :manage?

      repo = @collection.github_repos.find_by(id: params[:id], user: current_user)

      if repo.webhook_id
        client = Octokit::Client.new(access_token: current_user.github_access_token)
        begin
          client.remove_hook(
            repo.repo_name,
            repo.webhook_id
          )
        rescue Octokit::Error
          # Ignore if hook is already gone or user lost access
        end
      end

      repo.destroy
      flash[:success] = 'The GitHub repository has been successfully unlinked from this collection.'
      redirect_to collection_github_integrations_path(@collection.druid)
    end

    private

    def set_collection
      @collection = Collection.find_by(druid: params[:collection_druid])
    end
  end
end
