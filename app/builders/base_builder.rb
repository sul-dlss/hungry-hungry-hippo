# frozen_string_literal: true

# Base class for builders that build form values from Cocina objects
class BaseBuilder
  def self.call(...)
    new(...).call
  end

  def initialize(cocina_object:)
    @cocina_object = cocina_object
  end

  def call
    raise NotImplementedError
  end

  private

  attr_reader :cocina_object
end
