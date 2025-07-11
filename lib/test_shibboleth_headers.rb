# frozen_string_literal: true

# This is a Rack middleware that we use in testing. It injects headers
# that simulate mod_shib so we can test.
# This is added to the test environment configuration in config/environments/test.rb.
class TestShibbolethHeaders
  def initialize(app)
    @app = app
  end

  def call(env) # rubocop:disable Metrics/AbcSize
    # The /test_login endpoint sets cookies that provide the values for the headers.
    # Tests call /test_login via sign_in() helper method before a test.
    request = Rack::Request.new(env)
    if request.cookies['test_shibboleth_remote_user']
      env[mangle(Authentication::REMOTE_USER_HEADER)] = request.cookies['test_shibboleth_remote_user']
      env[mangle(Authentication::FULL_NAME_HEADER)] = request.cookies['test_shibboleth_full_name']
      env[mangle(Authentication::FIRST_NAME_HEADER)] = request.cookies['test_shibboleth_first_name']
    end

    if request.cookies['test_shibboleth_groups'].present?
      env[mangle(Authentication::USER_GROUPS_HEADER)] = request.cookies['test_shibboleth_groups']
    end

    @app.call(env)
  end

  # Transform the header key into the format that Rack expects.
  def mangle(key)
    "HTTP_#{key.upcase.tr('-', '_')}"
  end
end
