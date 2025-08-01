# frozen_string_literal: true

namespace :development do
  desc 'Complete accession workflow for a work or collection'
  task :accession, [:druid] => :environment do |_t, args|
    raise 'Only works in development mode!' unless Rails.env.development?

    druid = args[:druid]

    Dor::Services::Client.object(druid).workflow('accessionWF').skip_all(note: 'Testing')

    object = Work.find_by(druid:) || Collection.find_by!(druid:)
    object.accession_complete!

    Turbo::StreamsChannel.broadcast_refresh_to object

    puts "Completed accession for #{druid}"
  end

  desc 'Removes works that will have not been saved or will not roundtrip'
  # rubocop:disable Metrics/BlockLength
  task :cleanup, [:dryrun] => :environment do |_t, args|
    Work.find_each do |work|
      dryrun = args[:dryrun] != 'false'
      if work.druid.blank?
        puts "Work #{work.id} has no druid, deleting"
        work.destroy! unless dryrun
        next
      end

      if work.deposit_registering_or_updating? && work.updated_at < 1.day.ago
        puts "Work #{work.id} with druid #{work.druid} is stuck registering or updating, deleting"
        work.destroy! unless dryrun
        next
      end

      cocina_object = Sdr::Repository.find(druid: work.druid)

      if cocina_object.structural.isMemberOf.empty?
        puts "Work #{work.id} with druid #{work.druid} has no collection, deleting"
        work.destroy! unless dryrun
        next
      end

      content = Contents::Builder.call(cocina_object:, user: work.user, work:)
      work_form = Form::WorkMapper.call(cocina_object:,
                                        doi_assigned: DoiAssignedService.call(cocina_object:, work:),
                                        agree_to_terms: true,
                                        version_description: nil, collection: work.collection)
      unless WorkRoundtripper.call(work_form:, cocina_object:, content:, notify: false)
        puts "Work #{work.id} with druid #{work.druid} will not roundtrip, deleting"
        work.destroy! unless dryrun
        next
      end
      puts "Work #{work.id} with druid #{work.druid} will roundtrip"
    end
  end
  # rubocop:enable Metrics/BlockLength
end
