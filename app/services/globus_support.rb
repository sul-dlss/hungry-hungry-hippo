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

  def self.work_path(work:, with_uploads_directory: false)
    path = "work-#{work.id}"
    return path unless with_uploads_directory

    with_uploads_directory(path:)
  end

  def self.local_work_path(work:)
    "#{Settings.globus.local_uploads_directory}#{work_path(work:)}"
  end

  def self.with_uploads_directory(path:)
    "#{Settings.globus.uploads_directory}#{path}"
  end
end
