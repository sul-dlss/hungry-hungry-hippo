# frozen_string_literal: true

module ToBibTex
  # Maps Cocina DRO to a BibTex object
  class Citation
    def self.call(...)
      new(...).call
    end

    def initialize(cocina_object:)
      @cocina_object = cocina_object
    end

    def call
      # work_type, work_subtypes = CocinaSupport.work_type_and_subtypes_for(cocina_object:)
      BibTeX::Entry.new do |entry|
        entry.type = :misc
        entry.key = cocina_object.externalIdentifier
        entry.title = CocinaSupport.title_for(cocina_object:)
        entry.author = CocinaSupport.authors_for(cocina_object:).map { |author| [author['last_name'], author['first_name']].join(', ') }.join(' and ')
        entry.year = CocinaSupport.event_date_for(cocina_object:, type: 'publication')[:year]
        # entry.keywords = CocinaSupport.keywords_for(cocina_object:)
      end
    end

    private

    attr_reader :cocina_object
  end
end