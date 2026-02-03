# frozen_string_literal: true

# Job to list files in a Globus endpoint and create ContentFile records.
class GlobusListJob < RetriableJob
  include Rails.application.routes.url_helpers

  def perform(content:, ahoy_visit:, cancel_check_interval: 100)
    @content = content
    @cancel_check_interval = cancel_check_interval
    @ahoy_visit = ahoy_visit

    GlobusClient.disallow_writes(user_id: user.email_address, path: globus_path, notify_email: false)

    content.globus_list!
    content.content_files.clear

    list_files

    if canceled?
      content.content_files.clear
      @event_name = Ahoy::Event::GLOBUS_CANCELLED
    else
      content.globus_list_complete!
      @event_name = Ahoy::Event::GLOBUS_LISTED
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
    AhoyEventService.call(name: @event_name, visit: @ahoy_visit, properties: ahoy_event_properties)
  end

  def globus_absolute_path
    GlobusSupport.with_uploads_directory(path: globus_path)
  end

  def canceled?
    content.reload.globus_not_in_progress?
  end

  def ahoy_event_properties
    {
      user_id: user.email_address,
      work_id: content.work.id,
      druid: content.work.druid,
      file_count: content.content_files.count,
      total_size: content.content_files.sum(:size)
    }
  end
end
