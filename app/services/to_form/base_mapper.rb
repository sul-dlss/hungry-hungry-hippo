# frozen_string_literal: true

module ToForm
  # Base class for mappers that convert Cocina::Models to form values
  class BaseMapper
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
end
