# frozen_string_literal: true

module ToWorkForm
  # Maps related works.
  class RelatedWorksMapper < ToForm::BaseMapper
    def call
      return if related_resources.blank?

      cocina_object.description.relatedResource.map do |related_resource|
        citation, identifier = related_work_values_from(related_resource)

        next if citation.blank? && identifier.blank?

        {
          'citation' => citation,
          'identifier' => identifier,
          'relationship' => related_resource.type,
          'use_citation' => citation.present?
        }
      end.compact_blank.presence
    end

    private

    def related_resources
      @related_resources ||= cocina_object.description.relatedResource
    end

    def related_work_values_from(related_resource) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return [] if RelatedWorkForm::RELATIONSHIP_TYPES.exclude?(related_resource.type)

      if related_resource.note&.first&.[](:type) == 'preferred citation'
        return [related_resource.note&.first&.[](:value), nil]
      end

      if related_resource.identifier&.first&.[](:uri).present?
        return [nil,
                related_resource.identifier&.first&.[](:uri)]
      end

      []
    end
  end
end
