# frozen_string_literal: true

RubyLLM.configure do |config|
  config.gemini_api_key = Settings.gemini_api.key
  config.logger = Rails.logger
end
