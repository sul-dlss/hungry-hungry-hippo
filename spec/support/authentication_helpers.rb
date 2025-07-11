# frozen_string_literal: true

# Helpers to assist with authentication.
module AuthenticationHelpers
  # Used by login and logout tests.
  def authentication_headers_for(user, groups: [])
    {
      Authentication::REMOTE_USER_HEADER => user.email_address,
      Authentication::FULL_NAME_HEADER => user.name,
      Authentication::FIRST_NAME_HEADER => user.first_name,
      Authentication::USER_GROUPS_HEADER => groups.join(';')
    }
  end

  def sign_in(user, groups: [], example: RSpec.current_example)
    if example.metadata[:type] == :system
      visit test_login_path(id: user.id, groups: groups.join(';'))
    else
      get test_login_path(id: user.id, groups: groups.join(';'))
    end
  end

  def request_sign_in(user, groups: [])
    visit test_login_path(id: user.id, groups: groups.join(';'))
  end

  RSpec.configure do |config|
    config.include AuthenticationHelpers, type: :system
    config.include AuthenticationHelpers, type: :request
  end
end
