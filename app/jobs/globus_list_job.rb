# frozen_string_literal: true

# Job to list files in a Globus endpoint and create ContentFile records.
class GlobusListJob < ApplicationJob
  include Rails.application.routes.url_helpers

  def perform(content:, cancel_check_interval: 100)
    @content = content
    @cancel_check_interval = cancel_check_interval

    GlobusClient.disallow_writes(user_id: user.email_address, path: globus_path, notify_email: false)

    content.globus_list!
    content.content_files.clear

    list_files

    if canceled?
      content.content_files.clear
    else
      content.globus_list_complete!
    end

    perform_broadcast
  end

  delegate :user, :work, to: :content

  attr_reader :content

  def list_files # rubocop:disable Metrics/AbcSize
    GlobusClient.list_files(user_id: user.email_address, path: globus_path, notify_email: false)
                .each_with_index do |file_info, index|
      # Only check for cancel every 100 files
      break if (index % @cancel_check_interval).zero? && canceled?

      filepath = Pathname.new(file_info.name).relative_path_from(globus_absolute_path).to_s
      next if IgnoreFileService.call(filepath:)

      ContentFile.create!(file_type: :globus, size: file_info.size, label: '', content:,
                          filepath:)
    end
  end

  def globus_path
    GlobusSupport.work_path(work:)
  end

  def perform_broadcast
    Turbo::StreamsChannel.broadcast_action_to 'show',
                                              content,
                                              action: :frame_reload,
                                              attributes: {
                                                frameTarget: ActionView::RecordIdentifier.dom_id(content, 'show')
                                              }
    Turbo::StreamsChannel.broadcast_action_to 'globus',
                                              content,
                                              action: :frame_redirect,
                                              attributes: {
                                                target: new_content_globus_path(content), frameTarget: 'globus'
                                              }
  end

  def globus_absolute_path
    GlobusSupport.with_uploads_directory(path: globus_path)
  end

  def canceled?
    content.reload.globus_not_in_progress?
  end
end
