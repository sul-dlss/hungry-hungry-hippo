# frozen_string_literal: true

module Sdr
  # Service to interact with SDR Event Service.
  class Event
    class Error < StandardError; end

    # If adding a new event here, make sure to add label to en.yml.
    EVENT_TYPES = %w[
      registration
      version_close
      update
      embargo_released
      collection_changed
      h3_collection_settings_updated
      h3_review_approved
      h3_review_returned
      h3_review_requested
      h3_globus_staged
    ].freeze

    # @param [String] druid
    # @param [String] type the type of event
    # @param [Hash] data the event data
    # @raise [Error] if there is an error creating the event
    def self.create(druid:, type:, data:)
      Dor::Event::Client.create(druid:, type:, data:) if Settings.rabbitmq.enabled
    rescue StandardError => e
      raise Error, "Failed to create event for #{druid}: #{e.message}"
    end

    # @param [String] druid
    # @return [Array<Dor::Services::Client::Events::Event>] the list of events for the given druid
    # @raise [Error] if there is an error creating the event
    def self.list(druid:)
      Dor::Services::Client.object(druid).events.list(event_types: EVENT_TYPES)
    rescue Dor::Services::Client::Error => e
      raise Error, "Listing events failed: #{e.message}"
    end
  end
end
