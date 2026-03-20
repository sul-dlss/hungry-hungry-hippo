# frozen_string_literal: true

# Methods for detecting URI types for identifier mappings
class UriSupport
  URI_TYPE_PATTERNS = {
    'doi' => 'doi.org',
    'arxiv' => 'arxiv.org',
    'pmid' => 'pubmed.ncbi.nlm.nih.gov'
  }.freeze

  def self.uri_type_for(identifier)
    URI_TYPE_PATTERNS.find { |_type, pattern| identifier.include?(pattern) }&.first
  end
end
