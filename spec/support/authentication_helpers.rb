# frozen_string_literal: true

# Helpers to assist with authentication.
module AuthenticationHelpers
  def authentication_headers_for(user, groups: [])
    {
      Authentication::REMOTE_USER_HEADER => user.email_address,
      Authentication::NAME_HEADER => user.name,
      Authentication::FIRST_NAME_HEADER => user.first_name,
      Authentication::GROUPS_HEADER => groups.join(';')
    }
  end

  def sign_in(user, groups: [])
    TestShibbolethHeaders.user = user
    TestShibbolethHeaders.groups = groups
  end

  private

  def clear_shibboleth_headers
    TestShibbolethHeaders.user = nil
    TestShibbolethHeaders.groups = nil
  end

  RSpec.configure do |config|
    # The class variables used in TestShibbolethHeaders can stick around between specs, so clearing.
    config.before(:each, type: :request) { clear_shibboleth_headers }
    config.before(:each, type: :system) { clear_shibboleth_headers }
    config.include AuthenticationHelpers, type: :system
    config.include AuthenticationHelpers, type: :request
  end
end
