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

  # rubocop:disable Metrics/AbcSize
  def call(env)
    if user
      env[mangle(Authentication::REMOTE_USER_HEADER)] = user.email_address
      env[mangle(Authentication::NAME_HEADER)] = user.name
      env[mangle(Authentication::FIRST_NAME_HEADER)] = user.first_name
    end
    env[Authentication::GROUPS_HEADER] = Array(groups).join(';') if groups
    @app.call(env)
  end
  # rubocop:enable Metrics/AbcSize

  # Transform the header key into the format that Rack expects.
  def mangle(key)
    "HTTP_#{key.upcase.tr('-', '_')}"
  end
end
