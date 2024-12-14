# frozen_string_literal: true

module ToBibTex
  # Maps Cocina DRO to a BibTex object
  class Citation
    def self.call(...)
      new(...).call
    end

    def initialize(cocina_object:)
      @cocina_object = cocina_object
      @bibliography = BibTeX::Bibliography.new
      @cp = CiteProc::Processor.new style: 'apa', format: 'text'
    end

    def call
      # work_type, work_subtypes = CocinaSupport.work_type_and_subtypes_for(cocina_object:)
      bibliography << cocina_to_bibtex
      cp.import bibliography.to_citeproc
      cp.render :bibliography, id: druid_sym
    end

    private

    attr_reader :cocina_object, :bibliography, :cp

    def cocina_to_bibtex
      BibTeX::Entry.new do |entry|
        entry.type = :misc
        entry.key = druid_sym
        entry.title = CocinaSupport.title_for(cocina_object:)
        entry.author = CocinaSupport.authors_for(cocina_object:).map { |author| [author['last_name'], author['first_name']].join(', ') }.join(' and ')
        entry.year = CocinaSupport.event_date_for(cocina_object:, type: 'publication')[:year]
        # entry.keywords = CocinaSupport.keywords_for(cocina_object:)
      end
    end

    def druid_sym
      cocina_object.externalIdentifier.split(':').last.to_sym
    end
  end
end
