# frozen_string_literal: true

module Sdr
  # Service to interact with SDR Event Service.
  class Event
    class Error < StandardError; end

    # @param [String] druid
    # @param [String] type the type of event
    # @param [Hash] data the event data
    # # @raise [Error] if there is an error creating the event
    def self.create(druid:, type:, data:)
      Dor::Event::Client.create(druid:, type:, data:) if Settings.rabbitmq.enabled
    rescue StandardError => e
      raise Error, "Failed to create event for #{druid}: #{e.message}"
    end
  end
end
