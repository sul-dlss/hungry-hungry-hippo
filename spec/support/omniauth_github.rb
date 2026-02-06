# frozen_string_literal: true

# Uses OmniAuth test mode for Github when configured with :omniauth_github
RSpec.configure do |config|
  config.around(:example, :omniauth_github) do |example|
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: 'github',
      uid: '123456',
      info: {
        nickname: 'testuser'
      },
      credentials: {
        token: 'test_token'
      }
    )
    example.run
    OmniAuth.config.test_mode = false
  end
end
