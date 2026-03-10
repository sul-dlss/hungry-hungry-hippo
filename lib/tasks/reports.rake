# frozen_string_literal: true

namespace :reports do
  # This Rake task generates reports on Globus deposit events,
  # including counts of created and staged events, file counts, deposit sizes, and unique users.
  desc 'Report on Globus deposit events'
  task globus: :environment do
    puts '** No Globus events found **' if globus_created.none?

    staged_count = 0
    file_counts = []
    deposit_sizes = []
    users = []

    visits.each do |visit_id|
      globus_staged_event = globus_staged(visit_id:)
      next if globus_staged_event.nil?

      staged_count += 1
      file_counts << globus_staged_event.properties['file_count'].to_i
      deposit_sizes << globus_staged_event.properties['total_size'].to_i
      users << globus_staged_event.properties['sunetid']
    end

    puts "Globus created events: #{globus_created.count}"
    puts "\tFirst event: #{first_event.time}" if first_event
    puts "Globus staged events: #{staged_count}"
    puts "\tLast event: #{last_event.time}" if last_event

    file_report(file_counts)
    deposit_report(deposit_sizes)
    puts "Unique users: #{users.uniq.count}" if users.any?
  end
end

# Prints a report of deposit sizes, including average, min, and max size
# param deposit_sizes [Array<Integer>] an array of deposit sizes in bytes
def deposit_report(deposit_sizes)
  return unless deposit_sizes.any?

  puts "Average deposit size: #{deposit_sizes.sum / deposit_sizes.size.to_f} bytes"
  puts "Min deposit size: #{deposit_sizes.min} bytes"
  puts "Max deposit size: #{deposit_sizes.max} bytes"
end

# Prints a report of file counts, including average, min, and max count
# param file_counts [Array<Integer>] an array of file counts
def file_report(file_counts)
  return unless file_counts.any?

  puts "Average file count: #{file_counts.sum / file_counts.size.to_f}"
  puts "Min file count: #{file_counts.min}"
  puts "Max file count: #{file_counts.max}"
end

def first_event
  @first_event ||= globus_created.first
end

def last_event
  @last_event ||= globus_created.last
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

# Returns an array of unique visit IDs that have "globus created" events
# return [Array<Integer>] an array of unique visit IDs
def visits
  globus_created.pluck(:visit_id).uniq
end
