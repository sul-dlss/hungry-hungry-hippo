# frozen_string_literal: true

namespace :development do
  desc 'Complete accession workflow for a work or collection'
  task :accession, [:druid] => :environment do |_t, args|
    raise 'Only works in development mode!' unless Rails.env.development?

    druid = args[:druid]

    client = Dor::Workflow::Client.new(url: Settings.workflow.url)
    client.skip_all(druid:, workflow: 'accessionWF', note: 'Testing')

    object = Work.find_by(druid:) || Collection.find_by!(druid:)
    object.accession_complete!

    puts "Completed accession for #{druid}"
  end
end
