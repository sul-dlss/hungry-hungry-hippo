# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.0.0'
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem 'propshaft'
# Use Postgres as the database for Active Record
gem 'pg'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'
# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem 'cssbundling-rails'
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem 'mission_control-jobs' # Rails-based frontend to Active Job adapters that support SolidQueue
gem 'solid_cable'
gem 'solid_cache'
gem 'solid_queue'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Additional gems
gem 'action_policy'
gem 'ahoy_matey' # Analytics
gem 'bunny' # RabbitMQ client
gem 'cocina-models'
gem 'config'
gem 'csv'
gem 'datacite'
gem 'dor-event-client'
gem 'dor-services-client'
gem 'dor-workflow-client', '>= 7.6.1'
gem 'druid-tools'
gem 'dry-monads'
gem 'edtf'
gem 'frozen_record' # For licenses
gem 'globus_client'
gem 'honeybadger'
gem 'kaminari' # For pagination
gem 'kicks' # Background processing of rabbitMQ messages. (Formerly sneakers.)
gem 'marcel' # For MIME type detection
gem 'okcomputer'
gem 'rack-sanitizer'
gem 'state_machines-activerecord'
gem 'validate_url'
gem 'view_component'
gem 'whenever', require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'erb_lint', require: false
  gem 'factory_bot_rails'
  gem 'rspec_junit_formatter' # used by CircleCI
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'simplecov', require: false
end

group :development do
  gem 'hotwire-spark'
  gem 'overmind'
  gem 'parallel' # Used for importing. Can be removed when importing is done.
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'capybara-playwright-driver'
  gem 'cyperful', require: false
  gem 'selenium-webdriver' # required by cyperful & dropzone system specs
  gem 'webmock'
end

group :deployment do
  gem 'capistrano-maintenance', '~> 1.2', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', require: false
  gem 'dlss-capistrano', require: false
end
