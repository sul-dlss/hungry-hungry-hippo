# frozen_string_literal: true

# A basic class for submitting Ahoy events from services and jobs
class AhoyEventService
  def self.call(...)
    new(...).call
  end

  # @param name [String] the name of the event (see Ahoy::Event names)
  # @param visit [Ahoy::Visit, nil] the Ahoy visit associated with the event
  # @param properties [Hash] additional properties to store with the event
  def initialize(name:, visit: nil, properties: {})
    @name = name
    @visit = visit
    @properties = properties
  end

  def call
    Ahoy::Event.create!(name:, visit:, properties:, time: Time.current) if visit.present?
  end

  private

  attr_reader :name, :visit, :properties
end
