# frozen_string_literal: true

# Generates the Cocina parameters for related works.
class RelatedWorksCocinaBuilder
  RELATION_TYPES = {
    'is supplement to' => { datacite: 'IsSupplementTo', cocina_type: 'supplement to' },
    'is supplemented by' => { datacite: 'IsSupplementedBy', cocina_type: 'supplemented by' },
    'is referenced by' => { datacite: 'IsReferencedBy', cocina_type: 'referenced by' },
    'references' => { datacite: 'References', cocina_type: 'references' },
    'is derived from' => { datacite: 'IsDerivedFrom', cocina_type: 'derived from' },
    'is source of' => { datacite: 'IsSourceOf', cocina_type: 'source of' },
    'is version of record' => { datacite: 'IsVersionOf', cocina_type: 'version of record' },
    'is version of' => { datacite: 'IsVersionOf', cocina_type: 'has version' },
    'is identical to' => { datacite: 'IsIdenticalTo', cocina_type: 'identical to' },
    'has version' => { datacite: 'HasVersion', cocina_type: 'has version' },
    'continues' => { datacite: 'Continues', cocina_type: 'preceded by' },
    'is continued by' => { datacite: 'IsContinuedBy', cocina_type: 'succeeded by' },
    'is part of' => { datacite: 'IsPartOf', cocina_type: 'part of' },
    'has part' => { datacite: 'HasPart', cocina_type: 'has part' },
    'is described by' => { datacite: 'IsDescribedBy', cocina_type: 'described by' },
    'describes' => { datacite: 'Describes', cocina_type: 'describes' },
    'has metadata' => { datacite: 'HasMetadata', cocina_type: 'describes' },
    'is metadata for' => { datacite: 'IsMetadataFor', cocina_type: 'described by' },
    'is documented by' => { datacite: 'IsDocumentedBy', cocina_type: 'described by' },
    'documents' => { datacite: 'Documents', cocina_type: 'describes' },
    'is variant form of' => { datacite: 'IsVariantFormOf', cocina_type: 'has version' },
    'is original form of' => { datacite: 'IsOriginalFormOf', cocina_type: 'has original version' }
  }.freeze
  def self.call(...)
    new(...).call
  end

  def initialize(related_works:)
    @related_works = related_works
  end

  def call
    related_works.map do |related_work|
      # NOTE: Sometimes this is an array of hashes and sometimes it's an array of RelatedWorkForm instances
      related_work = related_work.attributes if related_work.respond_to?(:attributes)
      next if related_work['citation'].blank? && related_work['identifier'].blank?

      related_work_params_for(related_work:)
    end.compact_blank
  end

  private

  attr_reader :related_works

  def related_work_params_for(related_work:)
    {
      type: RELATION_TYPES.dig(related_work['relationship'], :cocina_type),
      dataCiteRelationType: RELATION_TYPES.dig(related_work['relationship'], :datacite)
    }.compact.tap do |related_work_hash|
      related_work_hash.merge!(build_identifier(related_work['identifier']))

      if related_work['citation'].present?
        related_work_hash[:note] = [{ type: 'preferred citation', value: related_work['citation'] }]
      end
    end
  end

  # Build identifier or access cocina fields from form identifier value if present
  def build_identifier(identifier)
    if PurlSupport.purl?(url: identifier)
      { purl: identifier }
    # If the identifier is a URI, we need to specify the type
    elsif uri_type_for(identifier).present?
      { identifier:
            [{ uri: identifier, type: uri_type_for(identifier) }] }
    elsif identifier.blank?
      {}
    else
      { access: { url: [{ value: identifier }] } }
    end
  end

  def uri_type_for(identifier)
    return 'doi' if identifier.include?('doi.org')
    return 'arxiv' if identifier.include?('arxiv.org')

    'pmid' if identifier.include?('pubmed.ncbi.nlm.nih.gov')
  end
end
