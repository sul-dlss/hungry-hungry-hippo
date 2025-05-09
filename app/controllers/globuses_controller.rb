# frozen_string_literal: true

# Controller for Globus integration
class GlobusesController < ApplicationController
  before_action :set_content

  # Shows "I want to upload to Globus" button
  def new
    authorize! @content
  end

  # When the user clicks "I want to upload to Globus" button
  # Creates Globus directory, changes permissions, and redirects to uploading
  def create
    authorize! @content

    GlobusSetupJob.perform_later(user: current_user)

    redirect_to uploading_content_globuses_path(@content)
  end

  # Shows "I’m done uploading to Globus" button
  def uploading
    authorize! @content
    # This will need to handle paths for existing works.
    @destination_path = GlobusSupport.new_path(user: current_user)
  end

  # When the user clicks "I’m done uploading to Globus" button
  def done_uploading
    authorize! @content

    GlobusListJob.perform_later(content: @content)

    redirect_to wait_content_globuses_path(@content)
  end

  def wait
    authorize! @content
  end

  private

  def set_content
    @content = Content.find(params[:content_id])
  end
end
