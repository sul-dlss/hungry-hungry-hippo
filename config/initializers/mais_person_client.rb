# frozen_string_literal: true

MaisPersonClient.configure(
  api_key: Base64.decode64(Settings.person_api.key),
  api_cert: Base64.decode64(Settings.person_api.cert),
  base_url: Settings.person_api.url,
  user_agent: 'Stanford Digital Repository'
)
