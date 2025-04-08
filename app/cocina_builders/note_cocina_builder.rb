# frozen_string_literal: true

# Generates the Cocina parameters for a note
class NoteCocinaBuilder
  def self.call(...)
    new(...).call
  end

  def initialize(type:, value:, label: nil)
    @type = type
    @value = value
    @label = label
  end

  def call
    {
      type:,
      value:
    }.tap do |note|
      note[:displayLabel] = label if label
    end
  end

  private

  attr_reader :type, :value, :label
end
