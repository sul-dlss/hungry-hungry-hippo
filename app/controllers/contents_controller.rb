# frozen_string_literal: true

# Controller for a Work contents (files)
class ContentsController < ApplicationController
  before_action :set_content, only: %i[edit update show]

  def show
    authorize! @content

    @content_files = @content.content_files
  end

  def edit
    authorize! @content
  end

  def update
    authorize! @content

    update_files
    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_content
    @content = Content.find(params[:id])
  end

  # ActionDispath::Http::UploadedFile only provides the base name.
  # This attempts to get the complete filename from the headers.
  def filename_for(file)
    file.headers.match(/filename="(.+)"/)[1]
  end

  def update_files
    files = params[:content][:files].compact_blank
    files.each do |file|
      content_file = ContentFile.create!(content: @content, filename: filename_for(file), file_type: :attached,
                                         size: file.size, label: file.original_filename)
      content_file.file.attach(file)
    end
  end
end
