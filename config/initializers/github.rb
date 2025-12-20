# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, Settings.github.client_id, Settings.github.client_secret,
           scope: 'read:user,user:email,admin:repo_hook,read:org'
end
