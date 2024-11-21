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
        abstract:,
        related_links: CocinaSupport.related_links_for(cocina_object:),
        version: cocina_object.version
      }
    end

    def abstract
      cocina_object.description.note.find { |note| note.type == 'abstract' }&.value
    end
  end
end
