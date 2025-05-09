# frozen_string_literal: true

# Job to list files in a Globus endpoint and create ContentFile records.
class GlobusListJob < ApplicationJob
  include Rails.application.routes.url_helpers

  def perform(content:)
    @content = content

    endpoint_client.disallow_writes
    content.content_files.clear

    # TODO: Handle cancel

    endpoint_client.list_files.each do |file_info|
      next if IgnoreFileService.call(filepath: file_info.name)

      ContentFile.create!(file_type: :globus, size: file_info.size, label: '', content:, filepath: file_info.name)
    end

    perform_broadcast
  end

  delegate :user, to: :content

  attr_reader :content

  def endpoint_client
    @endpoint_client ||= GlobusClient::Endpoint.new(user_id: user.email_address, path: GlobusSupport.new_path(user:),
                                                    notify_email: false)
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
end
