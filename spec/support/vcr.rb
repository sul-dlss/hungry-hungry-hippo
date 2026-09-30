# frozen_string_literal: true

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  # To re-record a cassette, delete its file and re-run the spec; to add requests to an existing cassette,
  # use vcr: { record: :new_episodes } (rspec config/metadata on the spec file itself).
  c.allow_http_connections_when_no_cassette = false
  c.filter_sensitive_data('Bearer <LLM_API_KEY>') do |interaction|
    interaction.request.headers['Authorization']&.first
  end
  # Record the LiteLLM proxy under the placeholder base URL from settings.yml, whatever real base was used
  c.filter_sensitive_data('https://example.gateway.com/v1/') { Settings.lite_llm.base }
  # Don't record LiteLLM proxy internals (spend, rate limits, upstream project, etc.)
  c.before_record do |interaction|
    interaction.response.headers.reject! { |name, _| name.match?(/\AX-(Litellm|Ratelimit)-/i) }
  end
  c.ignore_localhost = true
end
