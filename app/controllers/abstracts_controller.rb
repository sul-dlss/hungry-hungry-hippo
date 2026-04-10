# frozen_string_literal: true

# Controller for handling abstract extraction from article files.
class AbstractsController < ApplicationController
  skip_verify_authorized only: %i[new clear]
  before_action :set_content_id, :set_doi
  layout false

  def new; end

  def create
    @content = Content.find(@content_id)
    authorize! @content, with: ContentPolicy

    filepath = article_filepath(@content)

    unless filepath
      @error = I18n.t('article_form.messages.upload_pdf_error')
      return render :new, status: :unprocessable_content
    end

    @abstract = ExtractAbstractService.call(filepath:)
    track_abstract_extraction
    return if @abstract

    @error = I18n.t('article_form.messages.extract_abstract_error')
    render :new, status: :unprocessable_content
  end

  private

  def article_filepath(content)
    content_file = content.content_files.where(extname: 'pdf').first
    return unless content_file

    ActiveStorageSupport.filepath_for_blob(content_file.file.blob)
  end

  def set_content_id
    @content_id = params[:content_id]
  end

  def set_doi
    @doi = params[:doi]
  end

  def track_abstract_extraction
    if @abstract.present?
      ahoy.track Ahoy::Event::ABSTRACT_EXTRACTED_SUCCESS, doi: @doi, abstract: @abstract
    else
      ahoy.track Ahoy::Event::ABSTRACT_EXTRACTED_FAILED, doi: @doi
    end
  end
end
