# frozen_string_literal: true

# Service for looking up metadata from Crossref based on a DOI and mapping it to form attributes.
class CrossrefService
  class Error < StandardError; end
  class NotFound < Error; end
  class NotJournalArticle < Error; end

  def self.call(...)
    new(...).call
  end

  def initialize(doi:)
    @doi = doi
  end

  # @return [Hash] attributes for a work form based on the Crossref metadata for the DOI
  # @raise [NotFound] if the DOI is not found in Crossref
  # @raise [NotJournalArticle] if the DOI is not a journal article
  def call
    Rails.cache.fetch(doi, namespace: 'crossref', expires_in: 1.month) do
      {
        title:,
        abstract:,
        related_works_attributes: [{
          relationship: 'is version of record',
          identifier: "https://doi.org/#{message['DOI']}"
        }],
        contributors_attributes: contributors_attrs,
        publication_date_attributes: publication_date_attrs
      }.compact_blank
    end
  end

  private

  attr_reader :doi

  def message # rubocop:disable Metrics/AbcSize
    @message ||= begin
      response = Faraday.get("https://api.crossref.org/works/doi/#{doi}")
      raise NotFound, "DOI '#{doi}' not found in Crossref" if response.status == 404
      raise Error, "DOI lookup failed: #{response.status} #{response.body}" unless response.success?

      JSON.parse(response.body)['message'].tap do |message|
        raise NotJournalArticle, "DOI '#{doi}' is not a journal article" unless message['type'] == 'journal-article'
      end
    end
  end

  def title
    strip_tags_and_comments(message['title']&.first)
  end

  def abstract
    abstract = message['abstract']

    return nil if abstract.blank?

    # Replace closing paragraph and title tags with double newlines for formatting
    normalized_abstract = abstract.gsub(%r{</jats:(title|p)>\n?\s*}, "\n\n")
                                  .gsub(%r{</?jats:.+?>\n?\s*}, '')
                                  .strip

    # Strip all remaining tags and comments
    strip_tags_and_comments(normalized_abstract)
  end

  def contributors_attrs
    Array(message['author']).map do |author|
      {
        first_name: strip_tags_and_comments(author['given']),
        last_name: strip_tags_and_comments(author['family']),
        person_role: 'author',
        orcid: author.key?('ORCID') ? author['ORCID'].split('/').last : nil,
        affiliations_attributes: affiliation_attrs_for(author)
      }.compact_blank
    end
  end

  def affiliation_attrs_for(author)
    Array(author['affiliation']).map do |affiliation|
      {
        institution: strip_tags_and_comments(affiliation['name']),
        uri: Array(affiliation['id']).select { |id| id['id-type'] == 'ROR' }.map { |id| id['id'] }.first
      }.compact
    end
  end

  def publication_date_attrs
    return unless message.key?('published')

    publication_date = message['published']['date-parts']
    { year: publication_date[0][0], month: publication_date[0][1], day: publication_date[0][2] }
  end

  # Strips all HTML/XML tags and comments from text
  # @param text [String, nil] the text to sanitize
  # @return [String, nil] the sanitized text, or nil if input is nil
  def strip_tags_and_comments(text)
    return nil if text.nil?

    text.gsub(/<!--.*?-->/m, '') # Remove XML/HTML comments
        .gsub(/<[^>]+>/, '').squeeze(' ') # Collapse multiple spaces (but not newlines) into one
        .strip
  end
end
