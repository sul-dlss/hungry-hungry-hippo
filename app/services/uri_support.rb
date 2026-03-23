# frozen_string_literal: true

# Methods for detecting URI types for identifier mappings
class UriSupport
  URI_TYPE_PATTERNS = {
    'doi' => 'doi.org',
    'arxiv' => 'arxiv.org',
    'pmid' => 'pubmed.ncbi.nlm.nih.gov'
  }.freeze

  # Determines the URI type for a given identifier by matching it against known patterns.
  #
  # @param identifier [String] the identifier to match against URI type patterns
  # @return [String, nil] the URI type corresponding to the identifier's pattern,
  #   or nil if no pattern matches
  def self.uri_type_for(identifier)
    URI_TYPE_PATTERNS.find { |_type, pattern| identifier.include?(pattern) }&.first
  end
end
