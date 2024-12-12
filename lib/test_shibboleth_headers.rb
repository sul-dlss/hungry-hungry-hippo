# frozen_string_literal: true

# This is a Rack middleware that we use in testing. It injects headers
# that simulate mod_shib so we can test.
# This is certainly not thread safe as it uses class level variables.
# This is added to the test environment configuration in config/environments/test.rb.
class TestShibbolethHeaders
  class_attribute :user
  class_attribute :groups

  def initialize(app)
    @app = app
  end

  def call(env) # rubocop:disable Metrics/AbcSize
    if user
      env[mangle(Settings.http_headers.remote_user)] = user.email_address
      env[mangle(Settings.http_headers.full_name)] = user.name
      env[mangle(Settings.http_headers.first_name)] = user.first_name
    end
    env[mangle(Settings.http_headers.user_groups)] = Array(groups).join(';') if groups
    @app.call(env)
  end

  # Transform the header key into the format that Rack expects.
  def mangle(key)
    "HTTP_#{key.upcase.tr('-', '_')}"
  end
end
