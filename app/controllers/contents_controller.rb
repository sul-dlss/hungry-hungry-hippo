# frozen_string_literal: true

# Controller for a Work contents (files)
class ContentsController < ApplicationController
  before_action :set_content, only: %i[edit update show show_table]
  before_action :set_content_files, only: %i[show show_table]

  # Called from work edit/update form.
  def show
    authorize! @content
  end

  # Called from work show page.
  def show_table
    authorize! @content
  end

  def edit
    authorize! @content
  end

  def update
    authorize! @content

    update_files

    # Broadcast the update to the content if completed
    if params[:content][:completed] == 'true'
      Turbo::StreamsChannel.broadcast_update_later_to @content, target: 'content-files', partial: 'contents/show',
                                                                locals: { content: @content }
    end

    head :ok
  end

  private

  def set_content
    @content = Content.find(params[:id])
  end

  def set_content_files
    @content_files = @content.content_files.order(filename: :asc).page(params[:page])
  end

  def update_files
    files = params[:content][:files]
    files.each do |index, file|
      # Dropzone controller is modified to provide the full path as content[:paths][index]
      path = params[:content][:paths][index]
      content_file = ContentFile.create_with(file_type: :attached, size: file.size, label: '')
                                .find_or_create_by!(content: @content, filename: path)
      content_file.file.attach(file)
    end
  end
end
