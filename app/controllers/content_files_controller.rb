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

  private

  def set_content_file
    @content_file = ContentFile.includes(:content).find(params[:id])
  end

  def content_file_params
    params.expect(content_file: %i[label hide])
  end
end
