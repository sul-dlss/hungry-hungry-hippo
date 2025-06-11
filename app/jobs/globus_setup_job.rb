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
    GlobusClient.mkdir(user_id: user.email_address, path:, notify_email: false)
  end

  def path
    # integration tests have a preset path based on work tile
    return Settings.globus.integration_endpoint if integration_test_work?

    # This will ignore if the directory already exists.
    work.present? ? GlobusSupport.work_path(work:) : GlobusSupport.user_path(user:)
  end

  # integration_mode is set to true in qa/stage for pre-set globus endpoint in integration tests based on work title
  def integration_test_work?
    Settings.globus.integration_mode && work.title&.ends_with?('Integration Test')
  end

  def allow_writes
    path = if work.present?
             GlobusSupport.work_path(work:, with_uploads_directory: true)
           else
             GlobusSupport.user_path(user:, with_uploads_directory: true)
           end
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
