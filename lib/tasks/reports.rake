# frozen_string_literal: true

require 'csv'

namespace :reports do
  # This Rake task generates reports on Globus deposit events,
  # including counts of created and staged events, file counts, deposit sizes, and unique users.
  desc 'Report on Globus deposit events'
  task globus: :environment do
    puts '** No Globus events found **' if globus_created.none?

    headers = %w[druid version sunetid deposit_started deposit_completed size file_count]

    CSV.open(report_path, 'w', write_headers: true, headers:) do |csv|
      globus_created.each do |created_event|
        csv << data_for_event(created_event).values
      end
    end

    puts "Report generated at #{report_path}"
  end
end

def data_for_event(created_event)
  {
    druid: created_event.properties['druid'],
    version: created_event.properties['version'],
    sunetid: created_event.properties['sunetid'],
    deposit_started: created_event.time
  }.merge(staged_event_data(visit_id: created_event.visit_id))
end

def staged_event_data(visit_id:)
  staged_event = globus_staged(visit_id:)
  return {} unless staged_event

  {
    deposit_completed: staged_event.time,
    size: staged_event.properties['total_size'],
    file_count: staged_event.properties['file_count']
  }
end

def report_path
  Rails.root.join('tmp', report_filename)
end

def report_filename
  "globus_deposit_report_#{Time.current.strftime('%Y%m%d%H%M%S')}.csv"
end

# Returns an ActiveRecord::Relation of all "globus created" events, ordered by time
# return [ActiveRecord::Relation] a relation of all "globus created" events
def globus_created
  @globus_created ||= Ahoy::Event.where_event('globus created').order(:time)
end

# Returns the first "globus staged" event for the given visit_id, or nil if no such event exists
# param visit_id [Integer] the ID of the visit to find the event for
# return [Ahoy::Event, nil] the first "globus staged" event for the visit, or nil if none exists
def globus_staged(visit_id:)
  Ahoy::Event.where_event('globus staged').where(visit_id:).order(:time).first
end
