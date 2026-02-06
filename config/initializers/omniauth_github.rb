# frozen_string_literal: true

# Disable CSRF protection in test mode
OmniAuth.config.request_validation_phase = if Rails.env.test?
                                             proc {}
                                           else
                                             OmniAuth::AuthenticityTokenProtection.new(key: :_csrf_token)
                                           end

OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, Settings.github.client_id, Settings.github.client_secret,
           scope: 'read:user,user:email,admin:repo_hook,read:org',
           callback_path: '/user/github/create'
end
