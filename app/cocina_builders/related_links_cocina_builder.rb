# frozen_string_literal: true

# Generates the Cocina parameters for related links.
class RelatedLinksCocinaBuilder
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
    {}.tap do |related_link_hash|
      related_link_text = related_link['text']
      related_link_hash[:title] = [{ value: related_link_text }] if related_link_text.present?

      url = related_link['url']
      if PurlSupport.purl?(url:)
        related_link_hash[:purl] = url
      elsif uri_type_for(url).present?
        related_link_hash[:identifier] = [{ uri: url, type: uri_type_for(url) }]
      else
        related_link_hash[:access] = { url: [{ value: related_link['url'] }] }
      end
    end
  end

  def uri_type_for(identifier)
    return 'doi' if identifier.include?('doi.org')
    return 'arxiv' if identifier.include?('arxiv.org')

    'pmid' if identifier.include?('pubmed.ncbi.nlm.nih.gov')
  end
end
