# frozen_string_literal: true

namespace :development do
  desc 'Complete accession workflow for a work'
  task :accession, [:druid] => :environment do |_t, args|
    raise 'Only works in development mode!' unless Rails.env.development?

    client = Dor::Workflow::Client.new(url: Settings.workflow.url)
    client.skip_all(druid: args[:druid], workflow: 'accessionWF', note: 'Testing')

    puts "Completed accessionWF for #{args[:druid]}"
  end
end
