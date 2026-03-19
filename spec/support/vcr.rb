# frozen_string_literal: true

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  # Set to true to create new cassettes or add vcr: { record: :new_episodes } to individual specs.
  c.allow_http_connections_when_no_cassette = false
  c.filter_sensitive_data('<GEMINI_API_KEY>') do |interaction|
    interaction.request.headers['X-Goog-Api-Key']&.first
  end
  c.ignore_localhost = true
end
