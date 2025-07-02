# frozen_string_literal: true

# Creates a Globus directory for a user than can be used to upload files for a new work.
# Note that until a draft is saved / deposited, the druid or work id is not known, hence using /new.
class GlobusSetupJob < ApplicationJob
  def perform(user:, content:)
    @user = user
    @content = content

    clear_content_files
    mkdir
    allow_writes
  end

  attr_reader :user, :content

  delegate :work, to: :content

  def mkdir
    # This will ignore if the directory already exists.
    path = GlobusSupport.work_path(work:)
    GlobusClient.mkdir(user_id: user.email_address, path:, notify_email: false)
  end

  def allow_writes
    path = GlobusSupport.work_path(work:, with_uploads_directory: true)
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
end
