# frozen_string_literal: true

# Controller for an Article
class ArticlesController < ApplicationController
  def new
    @collection = Collection.find_by!(druid: params.expect(:collection_druid))

    authorize! @collection, with: WorkPolicy

    @content = Content.create!(user: current_user)

    @article_form = article_form

    set_license_presenter
    ahoy.track Ahoy::Event::ARTICLE_FORM_STARTED, form_id: @article_form.form_id

    render :form
  end

  def create # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @article_form = ArticleForm.new(**article_form_params)
    @collection = Collection.find_by!(druid: @article_form.collection_druid)

    authorize! @collection, with: WorkPolicy

    @content = Content.find(@article_form.content_id)
    set_license_presenter

    if identifier_lookup?
      # Perform an identifier (DOI/PMCID) lookup and re-render the form showing the article metadata
      # (@article_work_form) if we are able to identify a valid DOI (either directly entered by the user
      # or via a lookup to Pubmed).  @article_form.valid? checks if the DOI is present and exists in Crossref.
      set_article_work_form if @article_form.valid?
      @article_form.last_doi_lookup = @article_form.doi # Keeps track if the user performed a DOI lookup.
      track_doi_lookup
      render :form, status: :unprocessable_content
    elsif @article_form.valid?(:deposit)
      # @article_form.valid?(:deposit) checks all of the fields.
      work = create_work
      work_form = create_article_work_form(article_form: @article_form, content: @content, work:)
      track_article_create(work:, work_form:)
      perform_deposit(work:, work_form:)
      redirect_to wait_articles_path(work.id)
    else
      # User tried to submit, but not all fields are valid.
      set_article_work_form if @article_form.doi.present? && @article_form.lookup_performed?
      render :form, status: :unprocessable_content
    end
  end

  def wait
    @work = Article.find(params[:id])
    authorize! @work, with: WorkPolicy

    # Don't show flashes on wait and preserve them for the next page
    @no_flash = true
    flash.keep

    return render 'works/wait' if @work.deposit_registering_or_updating?

    return redirect_to work_path(@work) if @work.accessioning?

    redirect_to edit_work_path(@work)
  end

  private

  def article_form
    ArticleForm.new(
      collection_druid: @collection.druid,
      content_id: @content.id,
      agree_to_terms: current_user.agree_to_terms?,
      license: @collection.license
    )
  end

  def track_article_create(work:, work_form:)
    ahoy.track Ahoy::Event::ARTICLE_FORM_COMPLETED, form_id: work_form.form_id, work_id: work.id
    ahoy.track Ahoy::Event::ARTICLE_CREATED, work_id: work.id, deposit: deposit?, review: request_review?
  end

  def track_doi_lookup
    identifier_type = @article_form.doi_identifier? ? 'DOI' : 'PMCID'
    event_type = if @article_form.doi_found? == false
                   Ahoy::Event::IDENTIFIER_LOOKUP_NOT_FOUND
                 elsif @article_form.doi_journal_article? == false
                   Ahoy::Event::IDENTIFIER_LOOKUP_NOT_ARTICLE
                 elsif @article_form.doi_has_complete_metadata? == false
                   Ahoy::Event::IDENTIFIER_LOOKUP_WITH_INCOMPLETE_METADATA
                 else
                   Ahoy::Event::IDENTIFIER_LOOKUP_SUCCESS
                 end

    ahoy.track event_type, identifier: @article_form.identifier, identifier_type:
  end

  def article_form_params
    params.expect(article: ArticleForm.permitted_params)
  end

  def perform_deposit(work:, work_form:)
    work.deposit_persist! # Sets the deposit state
    DepositWorkJob.perform_later(work:, work_form:, deposit: deposit?, request_review: false,
                                 current_user:, ahoy_visit:)
  end

  def identifier_lookup?
    params[:commit] == 'lookup'
  end

  def create_article_work_form(article_form:, content:, work:)
    attrs = article_form.attributes.slice(:collection_druid, :content_id, :agree_to_terms).merge(
      CrossrefService.call(doi: @article_form.doi)
    ).merge(
      whats_changing: 'Initial version',
      doi_option: 'no',
      work_type: 'Text',
      work_subtypes: ['Article'],
      creation_date: work.created_at.to_date,
      content_id: content.id,
      access: 'world', # Articles are always world access on creation
      collection_druid: @collection.druid,
      license: @article_form.license,
      article_version_identification: @article_form.article_version_identification
    )
    ArticleWorkForm.new(attrs)
  end

  def set_article_work_form
    @article_work_form = ArticleWorkForm.new(CrossrefService.call(doi: @article_form.doi))
  end

  def create_work
    title = ArticleWorkForm.new(CrossrefService.call(doi: @article_form.doi)).title
    Article.create!(title:, user: current_user, collection: @collection).tap do |work|
      @content.update!(work:)
    end
  end

  def set_license_presenter
    @license_presenter = LicensePresenter.new(work_form: @article_form, collection: @collection)
  end
end
