# frozen_string_literal: true

module Github
  # Service for downloading a GitHub release zip file or asset.
  class Downloader
    class DownloaderError < StandardError; end

    def initialize(url:)
      @url = url
    end

    def exist?
      response = connection.head(url)
      return true if response.success?
      return false if response.status == 404

      raise DownloaderError, "Failed to access #{url}: #{response.status} #{response.body}"
    end

    def download_to(file)
      resp = connection.get(url) do |req|
        req.options.on_data = proc do |chunk, _overall_received_bytes|
          file.write(chunk)
        end
      end

      raise DownloaderError, "Failed to download #{url}: #{resp.status} #{resp.body}" unless resp.success?
    end

    private

    attr_reader :url

    def connection
      @connection ||= Faraday.new do |f|
        f.response :follow_redirects
        f.adapter Faraday.default_adapter
      end
    end
  end
end
