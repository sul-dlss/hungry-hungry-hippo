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
      WorkForm.new(**params)
    end

    private

    attr_reader :cocina_object

    # rubocop:disable Metrics/AbcSize
    def params
      {
        druid: cocina_object.externalIdentifier,
        lock: cocina_object.lock,
        title: CocinaSupport.title_for(cocina_object:),
        abstract: CocinaSupport.abstract_for(cocina_object:),
        related_works_attributes: CocinaSupport.related_works_for(cocina_object:),
        related_links_attributes: CocinaSupport.related_links_for(cocina_object:),
        license:,
        version: cocina_object.version,
        collection_druid: CocinaSupport.collection_druid_for(cocina_object:),
        publication_date_attributes: CocinaSupport.event_date_for(cocina_object:, type: 'publication')
      }
    end
    # rubocop:enable Metrics/AbcSize

    def license
      cocina_object.access.license
    end
  end
end
