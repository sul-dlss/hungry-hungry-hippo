# frozen_string_literal: true

# Class for Pubmed API support, used to lookup a single DOI by PMID/PMCID
# https://pmc.ncbi.nlm.nih.gov/tools/idconv/
class PubmedService
  class Error < StandardError; end
  class NotFound < Error; end

  def self.call(...)
    new(...).call
  end

  def initialize(search:)
    @search = search
    @conn = new_conn
  end

  def call
    response = conn.get('/tools/idconv/api/v1/articles/', params, headers)
    validate_response!(response)
    extract_doi(response)
  rescue Faraday::ClientError, Faraday::ServerError => e
    raise Error, "Pubmed API error: #{e.message}"
  end

  attr_reader :conn, :search

  private

  def validate_response!(response)
    raise Error, "DOI lookup failed: #{response.status} #{response.body}" unless response_ok?(response)
    raise NotFound, 'DOI not found' if doi_missing?(response)
  end

  def response_ok?(response)
    response.success? || response.body['status'] == 'ok'
  end

  def extract_doi(response)
    response.body['records'].first['doi']
  end

  def doi_missing?(response)
    response.body['records'].blank? || extract_doi(response).blank?
  end

  def new_conn
    Faraday.new({ url: Settings.pubmed.url }) do |f|
      f.request :json
      f.response :json
      f.response :raise_error
    end
  end

  def headers
    {
      'Accept' => 'application/json',
      'User-Agent' => 'Stanford Self-Deposit (Hungry Hungry Hippo)'
    }
  end

  def params
    { ids: search, format: 'json', tool: 'my_tool', email: Settings.pubmed.email }
  end
end
