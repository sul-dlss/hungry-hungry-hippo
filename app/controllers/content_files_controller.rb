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

    status = Sdr::Repository.status(druid:)

    # if the object is accessioned and the file is not hidden, get it from the stacks
    if status.openable? && !@content_file.hide
      download_from_stacks
    # if the object is accessioned, get it from preservation
    elsif status.openable?
      download_from_preservation(status.version)
    # otherwise, get it from the staging area
    else
      download_from_staging
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  # this was borrowed from Argo without permission
  def download_from_preservation(version)
    # Set headers on the response before writing to the response stream
    send_file_headers!(
      type: 'application/octet-stream',
      disposition: 'attachment',
      filename: CGI.escape(filepath.split('/').last)
    )
    response.headers['Last-Modified'] = Time.now.utc.rfc2822 # HTTP requires GMT date/time

    Preservation::Client.objects.content(
      druid:,
      filepath:,
      version:,
      on_data: proc { |data, _count| response.stream.write data }
    )
  rescue Preservation::Client::NotFoundError => e
    # Undo the header setting above for the streaming response. Not relevant here.
    response.headers.delete('Last-Modified')
    response.headers.delete('Content-Disposition')

    render status: :not_found, plain: "Preserved file not found: #{e}"
  rescue Preservation::Client::Error => e
    message = "Preservation client error getting content of #{filepath} for #{druid}: #{e}"
    logger.error(message)
    Honeybadger.notify(message)
    render status: :internal_server_error, plain: message
  ensure
    response.stream.close
  end
  # rubocop:enable Metrics/AbcSize

  def download_from_stacks
    redirect_to "#{Settings.stacks.file_url}/#{druid}/#{filepath}", allow_other_host: true
  end

  def download_from_staging
    staging_filepath = StagingSupport.staging_filepath(druid:, filepath:)

    return head :bad_request unless File.exist?(staging_filepath)

    send_file staging_filepath, filename: filepath, type: @content_file.mime_type
  end

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
