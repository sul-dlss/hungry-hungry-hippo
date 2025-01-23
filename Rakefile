# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require 'sneakers/tasks'

Rails.application.load_tasks

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

  desc 'Run erblint against ERB files'
  task erblint: :environment do
    puts 'Running ERB linter...'
    system('bin/erb_lint --lint-all --format compact')
  end

  desc 'Run linter against JS files'
  task eslint: :environment do
    puts 'Running JS linter...'
    system('yarn run lint')
  end

  desc 'Run linter against style files'
  task stylelint: :environment do
    puts 'Running style linter...'
    system('yarn run stylelint')
  end

  desc 'Run all configured linters'
  task lint: %i[rubocop erblint eslint stylelint]
rescue LoadError
  # should only be here when gem group development and test aren't installed
end
