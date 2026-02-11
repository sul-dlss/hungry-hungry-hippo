# frozen_string_literal: true

require File.expand_path('environment', __dir__)

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
every 1.day do
  runner 'Content.where("created_at < ?", 3.days.ago).destroy_all', output: { standard: '/dev/null' }
end

# people are more likely to read their emails first thing in the morning?
every 1.day, at: '8:30 am' do
  runner 'TermsReminderEmailJob.perform_later'
end

every Settings.github.poll_interval.seconds do
  runner 'GithubRepository.where(github_deposit_enabled: true).find_each {|repo| PollGithubReleasesJob.perform_later(github_repository: repo)}' # rubocop:disable Layout/LineLength
end

every Settings.github.deposit_queue_interval.seconds do
  runner 'GithubRelease.where(status: ["queued", "failed"]).find_each {|release| DepositGithubReleaseJob.perform_later(github_release: release)}' # rubocop:disable Layout/LineLength
end
