# frozen_string_literal: true

# Job to list files in a Globus endpoint and create ContentFile records.
class GlobusListJob < ApplicationJob
  include Rails.application.routes.url_helpers

  def perform(content:, cancel_check_interval: 100)
    @content = content
    @cancel_check_interval = cancel_check_interval

    endpoint_client.disallow_writes

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

  def list_files
    endpoint_client.list_files.each_with_index do |file_info, index|
      # Only check for cancel every 100 files
      break if (index % @cancel_check_interval).zero? && canceled?

      filepath = file_info.name.delete_prefix(globus_path)
      next if IgnoreFileService.call(filepath:)

      ContentFile.create!(file_type: :globus, size: file_info.size, label: '', content:,
                          filepath:)
    end
  end

  def endpoint_client
    @endpoint_client ||= if work.present?
                           GlobusClient::Endpoint.new(user_id: user.email_address, path: GlobusSupport.path(work:),
                                                      notify_email: false)
                         else
                           GlobusClient::Endpoint.new(user_id: user.email_address, path: GlobusSupport.new_path(user:),
                                                      notify_email: false)
                         end
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

  def globus_path
    @globus_path ||= if work.present?
                       "#{GlobusSupport.path(work:, with_uploads_directory: true)}/"
                     else
                       "#{GlobusSupport.new_path(user:, with_uploads_directory: true)}/"
                     end
  end

  def canceled?
    content.reload.globus_not_in_progress?
  end
end
