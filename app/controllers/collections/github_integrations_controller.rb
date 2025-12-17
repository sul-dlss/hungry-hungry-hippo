# frozen_string_literal: true

module Collections
  # Controller to manage GitHub integrations for collections and linking of repos
  class GithubIntegrationsController < ApplicationController
    before_action :set_collection

    def index
      authorize! @collection, to: :manage?

      # if the user hasn't connected their GitHub account yet, redirect to the page that lets them connect their account
      unless current_user.github_connected?
        # store this page so we can redirect back here after auth is complete with github
        session[:return_to] = request.fullpath
        redirect_to github_integrations_path
        return
      end

      # currently linked repos for this collection
      @linked_repos = @collection.github_repos.where(user: current_user).index_by(&:repo_name)

      # Fetching all repos the user has access to. Pagination might be needed for users with many repos.
      client = Octokit::Client.new(access_token: current_user.github_access_token)
      @repos = client.repos(nil, type: 'public', sort: :updated, per_page: 100).map do |repo|
        {
          name: repo.full_name,
          id: repo.id,
          linked: @linked_repos.key?(repo.full_name),
          github_repo_id: @linked_repos[repo.full_name]&.id
        }
      end
    end

    # Link a GitHub repository to the collection and set up a webhook
    def create
      authorize! @collection, to: :manage?

      # TODO: this should all happen in a job and be async
      # TODO: if any parts of it fail, we need to roll back the previous steps
      # We then need to use ActionCable or similar to update the UI when done

      repo_name = params[:repo_name] # This should be full_name e.g. "owner/repo"
      repo_id = params[:repo_id]

      # Create the draft work immediately so we can get a druid and DOI
      content = Content.create!(user: current_user)

      work = Work.create!(collection: @collection, title: repo_name, user: current_user)
      content.update(work:)
      work.deposit_persist! # Sets the deposit state
      work_form = WorkForm.new(
        collection_druid: @collection.druid,
        title: repo_name,
        content_id: content.id,
        license: @collection.license,
        access: @collection.stanford_access? ? 'stanford' : 'world',
        agree_to_terms: @collection.user.agree_to_terms?,
        contact_emails_attributes: [{ email: @collection.user.email_address }],
        work_type: @collection.work_type,
        work_subtypes: @collection.work_subtypes,
        works_contact_email: @collection.works_contact_email
      )
      work_form.max_release_date = @collection.max_release_date if @collection.depositor_selects_release_option?
      work_form.creation_date = work.created_at.to_date
      DepositWorkJob.perform_later(work:, work_form:, deposit: false, request_review: false,
                                   current_user:)

      # Create the GitHub repo integration, which will also create a webhook via before_create callback
      @collection.github_repos.create!(
        repo_id:,
        repo_name:,
        work_id: work.id,
        user: current_user
      )

      respond_to do |format|
        format.html do
          flash[:success] = I18n.t('github.connected_to_collection')
          redirect_to collection_github_integrations_path(@collection.druid)
        end
        format.json { head :ok }
      end
    rescue StandardError => e
      respond_to do |format|
        format.html do
          flash[:danger] = I18n.t('github.error_connecting_to_collection', error_message: e.message)
          redirect_to collection_github_integrations_path(@collection.druid)
        end
        format.json { render json: { error: e.message }, status: :unprocessable_content }
      end
    end

    def destroy
      authorize! @collection, to: :manage?

      begin
        repo = @collection.github_repos.find_by(id: params[:id], user: current_user)
        repo.destroy

        respond_to do |format|
          format.html do
            flash[:success] = I18n.t('github.disconnected_from_collection')
            redirect_to collection_github_integrations_path(@collection.druid)
          end
          format.json { head :ok }
        end
      rescue StandardError => e
        respond_to do |format|
          format.html do
            flash[:danger] = I18n.t('github.error_disconnecting_from_collection', error_message: e.message)
            redirect_to collection_github_integrations_path(@collection.druid)
          end
          format.json { render json: { error: e.message }, status: :unprocessable_content }
        end
      end
    end

    private

    def set_collection
      @collection = Collection.find_by(druid: params[:collection_druid])
    end
  end
end
