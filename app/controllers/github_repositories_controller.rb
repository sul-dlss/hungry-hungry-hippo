# frozen_string_literal: true

# Controller for a Github Repository
class GithubRepositoriesController < ApplicationController
  def new
    @collection = Collection.find_by!(druid: params.expect(:collection_druid))

    authorize! @collection, with: WorkPolicy

    @github_repository_form = GithubRepositoryForm.new(collection_druid: @collection.druid)

    render :form
  end

  def create # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @github_repository_form = GithubRepositoryForm.new(github_repository_form_params)
    @collection = Collection.find_by!(druid: @github_repository_form.collection_druid)
    authorize! @collection, with: WorkPolicy

    if @github_repository_form.valid?
      github_repository_info = Github::AppService.repository(@github_repository_form.repository)
      github_repository_work_form = GithubRepositoryWorkForm.new(**github_repository_attrs(github_repository_info:))
      github_repository = GithubRepository.create!(title: github_repository_info.name, user: current_user,
                                                   github_repository_id: github_repository_info.id,
                                                   github_repository_name: github_repository_info.name,
                                                   collection: @collection)
      content = Content.create!(user: current_user, work: github_repository)
      github_repository_work_form.content_id = content.id
      github_repository_work_form.creation_date = Time.current.to_date
      perform_deposit(github_repository:, github_repository_work_form:)
      track_work_create(github_repository:)
      redirect_to wait_github_repositories_path(github_repository.id)
    else
      render :form, status: :unprocessable_content
    end
  end

  def wait
    @work = GithubRepository.find(params[:id])
    authorize! @work, with: WorkPolicy

    # Don't show flashes on wait and preserve them for the next page
    @no_flash = true
    flash.keep

    return redirect_to edit_work_path(@work) unless @work.deposit_registering_or_updating?

    render 'works/wait'
  end

  def poll
    @work = GithubRepository.find_by(druid: params[:druid])
    authorize! @work, with: WorkPolicy

    PollGithubReleasesJob.perform_later(github_repository: @work, immediate_deposit: true)

    flash[:success] = 'Checking for new releases. Depositing any new releases may take several hours.' # rubocop:disable Rails/I18nLocaleTexts
    redirect_to work_path(@work)
  end

  private

  def github_repository_form_params
    params.expect(github_repository: GithubRepositoryForm.permitted_params)
  end

  def perform_deposit(github_repository:, github_repository_work_form:)
    github_repository.deposit_persist! # Sets the deposit state
    DepositWorkJob.perform_later(work: github_repository, work_form: github_repository_work_form, deposit: false,
                                 request_review: false, current_user:)
  end

  def track_work_create(github_repository:)
    ahoy.track Ahoy::Event::WORK_CREATED, work_id: github_repository.id, deposit: false, review: false
  end

  def github_repository_attrs(github_repository_info:)
    {
      title: github_repository_info.name,
      abstract: github_repository_info.description,
      collection_druid: @github_repository_form.collection_druid,
      license: @collection.license,
      contact_emails_attributes: [{ email: current_user.email_address }],
      whats_changing: 'Initial version',
      doi_option: 'yes',
      work_type: 'Software/Code',
      related_works_attributes: [{
        relationship: 'is derived from',
        identifier: github_repository_info.url
      }]
    }
  end
end
