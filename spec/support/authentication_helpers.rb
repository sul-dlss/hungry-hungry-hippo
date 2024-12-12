# frozen_string_literal: true

# Helpers to assist with authentication.
module AuthenticationHelpers
  def authentication_headers_for(user, groups: [])
    {
      Settings.http_headers.remote_user => user.email_address,
      Settings.http_headers.full_name => user.name,
      Settings.http_headers.first_name => user.first_name,
      Settings.http_headers.user_groups => groups.join(';')
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
