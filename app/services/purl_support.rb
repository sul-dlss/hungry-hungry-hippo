# frozen_string_literal: true

# Methods for PURL support
class PurlSupport
  def self.purl?(url:)
    normalize_https(url:)&.start_with?(Settings.purl.url) || false
  end

  def self.normalize_https(url:)
    url&.sub(/^https?/, 'https')
  end
end
