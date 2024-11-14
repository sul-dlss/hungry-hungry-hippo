# frozen_string_literal: true

module ToWorkForm
  # Maps Cocina DRO to WorkForm
  class Mapper
    def self.call(...)
      new(...).call
    end

    def initialize(cocina_object:)
      @cocina_object = cocina_object
    end

    def call
      WorkForm.new(params)
    end

    private

    attr_reader :cocina_object

    def params
      {
        druid: cocina_object.externalIdentifier,
        title: CocinaSupport.title_for(cocina_object:)
      }
    end
  end
end
