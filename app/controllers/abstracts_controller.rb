# frozen_string_literal: true

# Controller for handling abstract extraction from article files.
class AbstractsController < ApplicationController
  skip_verify_authorized only: %i[new clear]
  before_action :set_content_id
  layout false

  def new; end

  def create
    content = Content.find(@content_id)
    authorize! content, with: ContentPolicy

    filepath = article_filepath(content)

    unless filepath
      @error = 'Upload your article as a PDF to use this feature.'
      return render :new, status: :unprocessable_content
    end

    @abstract = ExtractAbstractService.call(filepath:)
  end

  def clear; end

  private

  def article_filepath(content)
    content_file = content.content_files.where(extname: 'pdf').first
    return unless content_file

    ActiveStorageSupport.filepath_for_blob(content_file.file.blob)
  end

  def set_content_id
    @content_id = params[:content_id]
  end
end
