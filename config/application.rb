# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
require 'action_cable/engine'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HungryHungryHippo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Sanitize malformed characters in requests to prevent alerts like https://app.honeybadger.io/projects/77112/faults/118640601
    config.middleware.insert 0, Rack::Sanitizer

    # Add timestamps to all loggers (both Rack-based ones and e.g. Sidekiq's)
    config.log_formatter = proc do |severity, datetime, _progname, msg|
      "[#{datetime.to_fs(:iso8601)}] [#{severity}] #{msg}\n"
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Configure MissionControl-Jobs authentication/authorization
    config.mission_control.jobs.base_controller_class = 'MissionControlAuthorizationController'
    config.mission_control.jobs.http_basic_auth_enabled = false

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Use SQL schema format so we can have nice things like Postgres enums
    config.active_record.schema_format = :sql

    config.autoload_once_paths += Dir[Rails.root.join('app/serializers')] # rubocop:disable Rails/RootPathnameMethods

    config.action_dispatch.rescue_responses['Sdr::Repository::NotFoundResponse'] = :not_found

    # Bootstrap form error handling
    ActionView::Base.field_error_proc = proc do |html_tag, _instance|
      html_tag.gsub(/(form-control|form-check-input|form-select)/, '\1 is-invalid').html_safe # rubocop:disable Rails/OutputSafety
    end
  end
end
