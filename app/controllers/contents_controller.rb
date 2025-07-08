# frozen_string_literal: true

# Controller for a Work contents (files)
class ContentsController < ApplicationController
  before_action :set_content, only: %i[update show show_table]
  before_action :set_content_files, only: %i[show show_table]

  # Called from work edit/update form.
  def show
    authorize! @content

    # since the user can search by filename when pagination is occurring, this can result in @content_files
    # query having 0 results even when the object itself has files ... and we want to know how many files the
    # object has before a search to properly render the "no files" or "no search results" message as appropriate
    @total_files = total_files
    @search_term = search_term
  end

  # Called from work show page.
  def show_table
    authorize! @content

    version_status = Sdr::Repository.status(druid: params[:druid])
    @work_presenter = WorkPresenter.new(work: @content.work, version_status:,
                                        work_form: WorkForm.new(druid: params[:druid]))
  end

  def update
    authorize! @content

    if valid?
      update_files
      head :ok
    else
      render json: { error: 'Unable to upload file due to: Duplicate file. Delete the file and try again.' },
             status: :unprocessable_entity
    end
  end

  private

  def set_content
    @content = Content.find(params[:id])
  end

  def set_content_files
    @content_files = @content.content_files
    @content_files = @content_files.where('filepath like ?', "%#{search_term}%") if search_term
    @content_files = @content_files.path_order
    # if we have more than the configured number of files that will work with a hiearchical view,
    # we will do a flat list with paging, so add the page method and current page param to the query
    @content_files = @content_files.page(params[:page]) if total_files > Settings.file_upload.hierarchical_files_limit
  end

  def search_term
    params[:q]
  end

  # the total number of files in an object before any search filters are applied
  def total_files
    @content.content_files.count
  end

  def valid?
    files = params[:content][:files]
    files.each_key do |index|
      # Dropzone controller is modified to provide the full path as content[:paths][index]
      filepath = params[:content][:paths][index]
      next if IgnoreFileService.call(filepath:)

      return false if ContentFile.find_by(content: @content, filepath:)
    end

    true
  end

  def update_files
    files = params[:content][:files]
    files.each do |index, file|
      # Dropzone controller is modified to provide the full path as content[:paths][index]
      filepath = params[:content][:paths][index]
      next if IgnoreFileService.call(filepath:)

      content_file = ContentFile.create_with(file_type: :attached, size: file.size, label: '')
                                .find_or_create_by!(content: @content, filepath:)
      content_file.file.attach(file)
    end
  end
end
