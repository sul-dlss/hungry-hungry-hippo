# frozen_string_literal: true

module Form
  # Maps related links for collections only.
  class RelatedLinksMapper < BaseMapper
    def call
      return if related_resources.blank?

      related_resources.filter_map do |related_resource|
        if related_resource.access&.url.blank? && related_resource.purl.blank? && related_resource.identifier.empty?
          next
        end

        related_link_for(related_resource)
      end.presence
    end

    private

    def related_resources
      @related_resources ||= cocina_object.description.relatedResource
    end

    # rubocop:disable Style/SafeNavigationChainLength
    def related_link_for(related_resource)
      {
        'url' => related_resource.purl ||
          related_resource.access&.url&.first&.[](:value) ||
          related_resource.identifier.first[:uri],
        'text' => related_resource.title.first&.[](:value)
      }
    end
    # rubocop:enable Style/SafeNavigationChainLength
  end
end
