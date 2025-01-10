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

    def params # rubocop:disable Metrics/AbcSize
      {
        druid: cocina_object.externalIdentifier,
        lock: cocina_object.lock,
        title: CocinaSupport.title_for(cocina_object:),
        authors_attributes: CocinaSupport.authors_for(cocina_object:),
        abstract: CocinaSupport.abstract_for(cocina_object:),
        citation: CocinaSupport.citation_for(cocina_object:),
        auto_generate_citation: CocinaSupport.citation_for(cocina_object:).blank?,
        contact_emails_attributes: CocinaSupport.contact_emails_for(cocina_object:),
        related_works_attributes: CocinaSupport.related_works_for(cocina_object:),
        related_links_attributes: CocinaSupport.related_links_for(cocina_object:),
        keywords_attributes: CocinaSupport.keywords_for(cocina_object:),
        license: CocinaSupport.license_for(cocina_object:),
        access: CocinaSupport.access_for(cocina_object:),
        version: cocina_object.version,
        collection_druid: CocinaSupport.collection_druid_for(cocina_object:),
        publication_date_attributes: CocinaSupport.event_date_for(cocina_object:, type: 'publication')
      }.merge(work_type_params)
    end

    def work_type_params
      work_type, work_subtypes = CocinaSupport.work_type_and_subtypes_for(cocina_object:)
      if work_type == WorkType::OTHER
        return { work_type:, work_subtypes: [],
                 other_work_subtype: work_subtypes.first }
      end

      { work_type:, work_subtypes: }
    end
  end
end
