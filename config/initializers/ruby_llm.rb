# frozen_string_literal: true

RubyLLM.configure do |config|
  # We have a custom LiteLLM proxy service, so use the openai config for RubyLLM
  config.openai_api_key = Settings.lite_llm.key
  config.openai_api_base = Settings.lite_llm.base
  config.logger = Rails.logger
  # Total wait time before giving up on a request should be 60 seconds.
  config.request_timeout = 60
  config.max_retries = 0
end
