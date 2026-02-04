# Controller for an Article
class ArticlesController < ApplicationController
  def new
    @collection = Collection.find_by!(druid: params.expect(:collection_druid))

    authorize! @collection, with: WorkPolicy

    @article_form = ArticleForm.new(collection_druid: @collection.druid)

    # @content = Content.create!(user: current_user)
    # @work_form = new_work_form
    # set_license_presenter # Note this requires @collection and @work_form set above.
    # mark_collection_required_contributors # Note this requires @collection and @work_form set above.
    # ahoy.track Ahoy::Event::WORK_FORM_STARTED, form_id: @work_form.form_id

    render :form
  end

  def create
    @article_form = ArticleForm.new(article_form_params)
    @collection = Collection.find_by!(druid: @article_form.collection_druid)
    authorize! @collection, with: WorkPolicy

    if @article_form.valid?
      article_work_form = ArticleWorkForm.new(**article_attrs)
      article = Article.create!(title: article_work_form.title, user: current_user, collection: @collection)
      content = Content.create!(user: current_user, work: article)
      article_work_form.content_id = content.id
      article_work_form.creation_date = article.created_at.to_date
      # track_work_create(article)
      perform_deposit(article:, article_work_form:)
      flash[:info] =
        'Please review the information about your article. You can make changes before completing your deposit.'
      redirect_to wait_articles_path(article.id)
    else
      render :form, status: :unprocessable_content
    end
    #   # The validation_context param determines whether extra validations are applied, e.g., for deposits.
    #   if (@valid = @work_form.valid?(validation_context))
    #     work = Work.create!(title: @work_form.title, user: current_user, collection: @collection)
    #     @content.update!(work:)
    #     @work_form.creation_date = work.created_at.to_date
    #     track_work_create(work:)
    #     perform_deposit(work:)
    #     redirect_to wait_works_path(work.id)
    #   else
    #     handle_invalid
    #     set_license_presenter
    #     render :form, status: :unprocessable_content
    #   end
  end

  def wait
    @work = Article.find(params[:id])
    authorize! @work, with: WorkPolicy

    # Don't show flashes on wait and preserve them for the next page
    @no_flash = true
    flash.keep

    return redirect_to edit_work_path(@work) unless @work.deposit_registering_or_updating?

    render 'works/wait'
  end

  private

  def article_form_params
    params.expect(article: ArticleForm.permitted_params)
  end

  def article_attrs
    # 10.1128/mbio.01735-25
    response = Faraday.get("https://api.crossref.org/works/doi/#{@article_form.doi}")
    raise 'DOI lookup failed' unless response.success?

    article = JSON.parse(response.body)['message']
    Rails.logger.info(article.to_json)
    {
      title: article['title']&.first,
      abstract: article['abstract'],
      collection_druid: @article_form.collection_druid,
      whats_changing: 'Initial version',
      doi_option: 'no',
      related_works_attributes: [{
        relationship: 'is version of record',
        identifier: "https://doi.org/#{article['DOI']}"
      }]
      # journal_title: article.dig('container-title', 0)
    }.compact.tap do |attrs|
      if article.key?('published')
        publication_date = article['published']['date-parts']
        attrs[:publication_date_attributes] =
          { year: publication_date[0][0], month: publication_date[0][1], day: publication_date[0][2] }
      end
      attrs[:contributors_attributes] = Array(article['author']).map do |author|
        {
          first_name: author['given'],
          last_name: author['family'],
          person_role: 'author',
          orcid: author.key?('ORCID') ? author['ORCID'].split('/').last : nil
        }.tap do |contributor_attrs|
          contributor_attrs[:affiliations_attributes] = Array(author['affiliation']).map do |affiliation|
            {
              institution: affiliation['name'],
              uri: Array(affiliation['id']).select { |id| id['id-type'] == 'ROR' }.map { |id| id['id'] }.first
            }.compact
          end
        end
      end
    end
  end

  def perform_deposit(article:, article_work_form:)
    article.deposit_persist! # Sets the deposit state
    DepositWorkJob.perform_later(work: article, work_form: article_work_form, deposit: false, request_review: false,
                                 current_user:)
  end
end
