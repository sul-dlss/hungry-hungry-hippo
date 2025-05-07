# frozen_string_literal: true

# Support methods for Globus.
class GlobusSupport
  def self.endpoint_url(destination_path:, origin: nil)
    params = [
      "destination_id=#{Settings.globus.transfer_endpoint_id}",
      "destination_path=#{Settings.globus.uploads_directory}#{destination_path}"
    ]
    params << "origin_id=#{Settings.globus.origins[origin]}" if origin
    "https://app.globus.org/file-manager?#{params.join('&')}"
  end

  def self.new_path(user:)
    "#{user.sunetid}/new"
  end
end
