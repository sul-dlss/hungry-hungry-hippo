# frozen_string_literal: true

# Service for looking up metadata from Crossref based on a DOI and mapping it to form attributes.
class CrossrefService
  class Error < StandardError; end
  class NotFound < Error; end

  def self.call(...)
    new(...).call
  end

  def initialize(doi:)
    @doi = doi
  end

  # @return [Hash] attributes for a work form based on the Crossref metadata for the DOI
  # @raise [NotFound] if the DOI is not found in Crossref
  # @raise [Error] if the Crossref API request fails
  def call
    {
      title: message['title']&.first,
      abstract: normalize_abstract(message['abstract']),
      related_works_attributes: [{
        relationship: 'is version of record',
        identifier: "https://doi.org/#{message['DOI']}"
      }],
      contributors_attributes: contributors_attrs,
      publication_date_attributes: publication_date_attrs
    }.compact_blank
  end

  private

  attr_reader :doi

  def message
    @message ||= begin
      response = Faraday.get("https://api.crossref.org/works/doi/#{doi}")
      raise NotFound, "DOI '#{doi}' not found in Crossref" if response.status == 404
      raise Error, "DOI lookup failed: #{response.status} #{response.body}" unless response.success?

      JSON.parse(response.body)['message']
    end
  end

  def contributors_attrs
    Array(message['author']).map do |author|
      {
        first_name: author['given'],
        last_name: author['family'],
        person_role: 'author',
        orcid: author.key?('ORCID') ? author['ORCID'].split('/').last : nil,
        affiliations_attributes: affiliation_attrs_for(author)
      }.compact_blank
    end
  end

  def affiliation_attrs_for(author)
    Array(author['affiliation']).map do |affiliation|
      {
        institution: affiliation['name'],
        uri: Array(affiliation['id']).select { |id| id['id-type'] == 'ROR' }.map { |id| id['id'] }.first
      }.compact
    end
  end

  def publication_date_attrs
    return unless message.key?('published')

    publication_date = message['published']['date-parts']
    { year: publication_date[0][0], month: publication_date[0][1], day: publication_date[0][2] }
  end

  def normalize_abstract(abstract)
    abstract.gsub(%r{</jats:(title|p)>\n?\s*}, "\n\n")
            .gsub(%r{</?jats:.+?>\n?\s*}, '')
            .strip
  end
end
