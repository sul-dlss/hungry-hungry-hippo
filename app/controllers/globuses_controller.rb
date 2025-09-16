# frozen_string_literal: true

# Controller for Globus integration
class GlobusesController < ApplicationController
  layout false
  before_action :set_content
  before_action :set_destination_path, only: %i[uploading done_uploading]

  # Shows "I want to upload to Globus" button
  def new
    authorize! with: GlobusPolicy
  end

  # When the user clicks "I want to upload to Globus" button
  # Creates Globus directory, changes permissions, and redirects to uploading
  def create
    authorize! with: GlobusPolicy

    GlobusSetupJob.perform_later(user: current_user, content: @content)

    redirect_to uploading_content_globuses_path(@content)
  end

  # Shows "I’m done uploading to Globus" button
  def uploading
    authorize! with: GlobusPolicy
  end

  # When the user clicks "I’m done uploading to Globus" button
  def done_uploading
    authorize! with: GlobusPolicy

    return render :uploading, status: :unprocessable_content if (@tasks_in_progress = tasks_in_progress?)

    GlobusListJob.perform_later(content: @content)

    redirect_to wait_content_globuses_path(@content)
  end

  def wait
    authorize! with: GlobusPolicy
  end

  def cancel
    authorize! with: GlobusPolicy

    @content.globus_list_cancel! if @content.globus_listing?
    redirect_to new_content_globus_path(@content)
  end

  private

  def set_content
    @content = Content.find(params[:content_id])
  end

  def set_destination_path
    @destination_path = GlobusSupport.work_path(work: @content.work)
  end

  def implicit_authorization_target
    @content
  end

  def tasks_in_progress?
    # Note that this does not work for direct uploads in the browser.
    GlobusClient.tasks_in_progress?(destination_path: GlobusSupport.with_uploads_directory(path: @destination_path))
  end
end
