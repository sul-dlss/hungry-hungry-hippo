# frozen_string_literal: true

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
