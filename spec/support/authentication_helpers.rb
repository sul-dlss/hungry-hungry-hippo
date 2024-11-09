# frozen_string_literal: true

# Helpers to assist with authentication.
module AuthenticationHelpers
  def authentication_headers_for(user)
    {
      Authentication::REMOTE_USER_HEADER => user.email_address,
      Authentication::NAME_HEADER => user.name,
      Authentication::FIRST_NAME_HEADER => user.first_name
    }
  end

  def sign_in(user, groups: [])
    TestShibbolethHeaders.user = user
    TestShibbolethHeaders.groups = groups
  end

  RSpec.configure do |config|
    config.include AuthenticationHelpers, type: :system
    config.include AuthenticationHelpers, type: :request
  end
end
