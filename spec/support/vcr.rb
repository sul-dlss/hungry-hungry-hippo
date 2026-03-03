# frozen_string_literal: true

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = true
  c.filter_sensitive_data('<GEMINI_API_KEY>') do |interaction|
    interaction.request.headers['X-Goog-Api-Key']&.first
  end
end
