# frozen_string_literal: true

# Builds related links.
class RelatedLinksBuilder < BaseBuilder
  def call
    return if related_resources.blank?

    related_resources.filter_map do |related_resource|
      next if related_resource.access&.url.blank?

      related_link_for(related_resource)
    end.presence
  end

  private

  def related_resources
    @related_resources ||= cocina_object.description.relatedResource
  end

  def related_link_for(related_resource)
    {
      'url' => related_resource.access.url.first[:value],
      'text' => related_resource.title.first&.[](:value)
    }
  end
end
