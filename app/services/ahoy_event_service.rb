# frozen_string_literal: true

# A basic class for submitting Ahoy events from services and jobs
class AhoyEventService
  def self.call(...)
    new(...).call
  end

  def initialize(name:, visit:, properties: {})
    @name = name
    @visit = visit
    @properties = properties
  end

  def call
    Ahoy::Event.create!(name:, visit:, properties:, time: Time.current)
  end

  private

  attr_reader :name, :visit, :properties
end
