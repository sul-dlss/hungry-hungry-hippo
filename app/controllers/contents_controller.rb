# frozen_string_literal: true

# Controller for a Work contents (files)
class ContentsController < ApplicationController
  before_action :set_content, only: %i[edit update show]

  def show
    authorize! @content

    @content_files = @content.content_files.order(filename: :asc).page(params[:page])

    # This can be called from the work edit/update page or the work show page.
    # If from the show page, render the table.
    if Rails.application.routes.recognize_path(request.referer)[:action] == 'show'
      render :show_table
    else
      render :show
    end
  end

  def edit
    authorize! @content
  end

  def update
    authorize! @content

    update_files

    # Broadcast the update to the content
    Turbo::StreamsChannel.broadcast_update_later_to @content, target: 'content-files', partial: 'contents/show',
                                                              locals: { content: @content }

    head :ok
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
    files = params[:content][:files]
    files.each_value do |file|
      content_file = ContentFile.create_with(file_type: :attached, size: file.size, label: file.original_filename)
                                .find_or_create_by!(content: @content, filename: filename_for(file))
      content_file.file.attach(file)
    end
  end
end
