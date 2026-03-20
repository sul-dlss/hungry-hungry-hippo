# frozen_string_literal: true

RubyLLM.configure do |config|
  config.gemini_api_key = Settings.gemini_api.key
  config.vertexai_service_account_key = Base64.decode64(Settings.vertexai_api.key)
  config.vertexai_project_id = Settings.vertexai_api.project_id
  config.vertexai_location = Settings.vertexai_api.location
  config.logger = Rails.logger
end
