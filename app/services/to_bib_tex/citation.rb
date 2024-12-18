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
      debugger
      cp.import bibliography.to_citeproc
      cp.render :bibliography, id: druid_sym, format: :apa
    end

    private

    attr_reader :cocina_object, :bibliography, :cp

    def cocina_to_bibtex
      BibTeX::Entry.new do |entry|
        entry.type = :article
        entry.key = druid_sym
        entry.title = CocinaSupport.title_for(cocina_object:)
        entry.author = person_authors_string
        entry.organization = organization_authors_string
        entry.year = CocinaSupport.event_date_for(cocina_object:, type: 'publication')[:year]
        entry.keywords = CocinaSupport.keywords_for(cocina_object:).join(', ')
        entry.publisher = "Stanford Digital Repository"
        entry.howpublished = "\\url\{#{Settings.purl.url}/#{cocina_object.externalIdentifier}\}"
      end
    end

    def druid_sym
      cocina_object.externalIdentifier.split(':').last.to_sym
    end

    def person_authors_string
      CocinaSupport.authors_for(cocina_object:).select do |author|
        author['role_type'] == 'person'
      end.map do |author| 
        [author['last_name'], author['first_name']].join(', ')
      end.join(' and ')
    end

    def organization_authors_string
      CocinaSupport.authors_for(cocina_object:).select do |author|
        author['role_type'] == 'organization'
      end.map do |org|
        org['organization_name']
      end.join(' and ')
    end
  end
end

# BebTeX types:
# article (Cocina: Text/Article)
# book (Cocina: Text/Book)
# booklet
# conference (Cocina: Text/Conference session)
# inbook (Cocina: Text/Book chapter)
# incollection
# inproceedings (Cocina: ???/Conference session)
# manual (Cocina: Documentation)
# mastersthesis (Cocina: Thesis)
# misc
# phdthesis
# proceedings
# techreport (Cocina: Technical report)
# unpublished (Cocina: Working paper)

