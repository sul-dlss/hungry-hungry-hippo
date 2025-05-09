# frozen_string_literal: true

# Creates a Globus directory for a user than can be used to upload files for a new work.
# Note that until a draft is saved / deposited, the druid or work id is not known, hence using /new.
class GlobusSetupJob < ApplicationJob
  def perform(user:)
    @user = user

    Rails.logger.info "Creating Globus directory for user #{user.sunetid} at #{path}"

    endpoint_client.mkdir # This will ignore if the directory already exists.
    endpoint_client.allow_writes
  end

  attr_reader :user

  def endpoint_client
    @endpoint_client ||= GlobusClient::Endpoint.new(user_id: user.email_address, path:, notify_email: false)
  end

  def path
    @path ||= GlobusSupport.new_path(user:)
  end
end
