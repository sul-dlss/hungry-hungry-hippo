# frozen_string_literal: true

# Controller for a Work content file
class ContentFilesController < ApplicationController
  include ActionController::Live # required for streaming

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
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize! @content_file

    @content_file.destroy
    redirect_to content_path(@content_file.content)
  end

  def download
    authorize! @content_file

    # if the file is on the staging path, get it from there
    if File.exist?(@content_file.staging_filepath)
      send_file @content_file.staging_filepath, filename: filepath, type: @content_file.mime_type
    else # if not, get it from preservation
      download_from_preservation
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  # Note: for streaming to work, you need the include at the top of the controller
  def download_from_preservation
    # Set headers on the response before writing to the response stream
    send_file_headers!(
      type: 'application/octet-stream',
      disposition: 'attachment',
      filename: @content_file.filename
    )
    response.headers['Last-Modified'] = Time.now.utc.rfc2822 # HTTP requires GMT date/time

    Preservation::Client.objects.content(
      druid:,
      filepath:,
      on_data: proc { |data, _count| response.stream.write data }
    )
  rescue Preservation::Client::NotFoundError, Preservation::Client::Error => e
    message = "Preservation client error getting content of #{filepath} for #{druid}: #{e}"
    Honeybadger.notify(message)
    render status: :bad_request, plain: 'There was a problem downloading your file.  Please try again later.'
  ensure
    response.stream.close
  end
  # rubocop:enable Metrics/AbcSize

  def druid
    @content_file.work.druid
  end

  def filepath
    @content_file.filepath
  end

  def set_content_file
    @content_file = ContentFile.includes(:content).find(params[:id])
  end

  def content_file_params
    params.expect(content_file: %i[label hide])
  end
end
