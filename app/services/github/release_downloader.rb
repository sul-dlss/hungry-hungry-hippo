# frozen_string_literal: true

module Github
  # Service for downloading a GitHub release zip file.
  class ReleaseDownloader
    class ReleaseDownloaderError < StandardError; end

    def initialize(zip_url:)
      @zip_url = zip_url
    end

    def exist?
      response = connection.head(zip_url)
      return true if response.success?
      return false if response.status == 404

      raise ReleaseDownloaderError, "Failed to access release zip: #{response.status} #{response.body}"
    end

    def download_to(file)
      resp = connection.get(zip_url) do |req|
        req.options.on_data = proc do |chunk, _overall_received_bytes|
          file.write(chunk)
        end
      end

      raise ReleaseDownloaderError, "Failed to download release zip: #{resp.status} #{resp.body}" unless resp.success?
    end

    private

    attr_reader :zip_url

    def connection
      @connection ||= Faraday.new do |f|
        f.response :follow_redirects
        f.adapter Faraday.default_adapter
      end
    end
  end
end
