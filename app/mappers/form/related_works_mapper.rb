# frozen_string_literal: true

# The containing namespace for mappers indicates what is being mapped *to*
module Form
  # Maps related works.
  class RelatedWorksMapper < BaseMapper
    def call
      return if related_resources.blank?

      cocina_object.description.relatedResource.map do |related_resource|
        citation, identifier, relationship = related_work_values_from(related_resource)
        next if citation.blank? && identifier.blank?

        {
          'citation' => citation,
          'identifier' => identifier,
          'relationship' => relationship,
          'use_citation' => citation.present?
        }
      end.compact_blank.presence
    end

    private

    def related_resources
      @related_resources ||= cocina_object.description.relatedResource
    end

    def related_work_values_from(related_resource) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      # only map relationships that are supported relationship types
      if related_resource.type.present? && !related_work_type?(related_resource)
        []
      elsif related_resource.note&.first&.[](:type) == 'preferred citation'
        [related_resource.note&.first&.[](:value), nil, relationship(related_resource)]
      elsif related_resource.identifier&.first&.[](:uri).present?
        [nil, related_resource.identifier&.first&.[](:uri), relationship(related_resource)]
      end
    end

    def related_work_type?(related_resource)
      cocina_types = RelatedWorksCocinaBuilder::RELATION_TYPES.map { |_, relation| relation[:cocina_type] }
      cocina_types.include?(related_resource.type)
    end

    def relationship(related_resource)
      datacite_type = related_resource.dataCiteRelationType
      return nil if datacite_type.blank?

      cocina_type = related_resource.type
      # we have to match both the datacite and cocina types to find the relationship
      # because there are a few cases where more than one datacite type is possible for a given cocina type
      RelatedWorksCocinaBuilder::RELATION_TYPES.select do |_, value|
        value[:datacite] == datacite_type && value[:cocina_type] == cocina_type
      end.keys.first
    end
  end
end
