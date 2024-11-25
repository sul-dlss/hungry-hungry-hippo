# frozen_string_literal: true

module ToCollectionForm
  # Maps Cocina Collection to CollectionForm
  class Mapper
    def self.call(...)
      new(...).call
    end

    def initialize(cocina_object:)
      @cocina_object = cocina_object
    end

    def call
      CollectionForm.new(params)
    end

    private

    attr_reader :cocina_object

    def params
      {
        druid: cocina_object.externalIdentifier,
        lock: cocina_object.lock,
        title: CocinaSupport.title_for(cocina_object:),
        description: CocinaSupport.abstract_for(cocina_object:), # Cocina abstract maps to Collection description
        related_links: CocinaSupport.related_links_for(cocina_object:),
        version: cocina_object.version
      }
    end
  end
end
