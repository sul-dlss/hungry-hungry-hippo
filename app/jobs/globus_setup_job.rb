# frozen_string_literal: true

# Creates a Globus directory for a user than can be used to upload files for a new work.
# Note that until a draft is saved / deposited, the druid or work id is not known, hence using /new.
class GlobusSetupJob < RetriableJob
  def perform(user:, content:, ahoy_visit:)
    @user = user
    @content = content
    @ahoy_visit = ahoy_visit

    clear_content_files
    mkdir
    allow_writes

    AhoyEventService.call(
      name: Ahoy::Event::GLOBUS_CREATED,
      visit: @ahoy_visit,
      properties: ahoy_event_properties
    )
  end

  attr_reader :user, :content

  delegate :work, to: :content

  def mkdir
    # This will ignore if the directory already exists.
    GlobusClient.mkdir(user_id: user.email_address, path:, notify_email: false)
  end

  def allow_writes
    GlobusClient.allow_writes(user_id: user.email_address, path:, notify_email: false)
  end

  def clear_content_files
    content.content_files.clear
    Turbo::StreamsChannel.broadcast_action_to 'show',
                                              content,
                                              action: :frame_reload,
                                              attributes: {
                                                frameTarget: ActionView::RecordIdentifier.dom_id(content, 'show')
                                              }
  end

  def path
    @path ||= GlobusSupport.work_path(work:)
  end

  def ahoy_event_properties
    {
      user_id: user.email_address,
      work_id: content.work.id,
      druid: content.work.druid
    }
  end
end
