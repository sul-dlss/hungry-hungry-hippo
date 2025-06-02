# frozen_string_literal: true

# Controller for a Work content file
class ContentFilesController < ApplicationController
  before_action :set_content_file

  def show
    authorize! @content_file
  end

  def edit
    authorize! @content_file
  end

  def update
    authorize! @content_file

    if @content_file.update(content_file_params)
      redirect_to content_file_path(@content_file)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! @content_file

    @content_file.destroy
    redirect_to content_path(@content_file.content)
  end

  def download
    authorize! @content_file

    staging_filepath = StagingSupport.staging_filepath(druid: @content_file.content.work.druid,
                                                       filepath: @content_file.filepath)
    return head :bad_request unless File.exist?(staging_filepath)

    send_file staging_filepath, filename: @content_file.filename, type: @content_file.mime_type
  end

  private

  def set_content_file
    @content_file = ContentFile.includes(:content).find(params[:id])
  end

  def content_file_params
    params.expect(content_file: %i[label hide])
  end
end
