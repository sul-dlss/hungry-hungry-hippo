# frozen_string_literal: true

module CocinaGenerators
  class Description
    # Generates the Cocina parameters for related links.
    class RelatedLinks
      def self.call(...)
        new(...).call
      end

      def initialize(related_links:)
        @related_links = related_links
      end

      def call
        related_links.map do |related_link|
          # NOTE: Sometimes this is an array of hashes and sometimes it's an array of RelatedLinkForm instances
          related_link = related_link.attributes if related_link.respond_to?(:attributes)
          next if related_link['url'].blank?

          related_link_params_for(related_link:)
        end.compact_blank
      end

      private

      attr_reader :related_links

      def related_link_params_for(related_link:)
        {
          access: {
            url: [
              { value: related_link['url'] }
            ]
          }
        }.tap do |related_link_hash|
          next if (related_link_text = related_link['text']).blank?

          related_link_hash[:title] = [{ value: related_link_text }]
        end
      end
    end
  end
end
