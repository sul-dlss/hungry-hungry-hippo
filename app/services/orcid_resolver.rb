# frozen_string_literal: true

# This resolves an ORCID ID to an ORCID entity from ORCID.org
class OrcidResolver
  include Dry::Monads[:result]

  # @see OrcidResolver#initialize, OrcidResolver#call
  def self.call(...)
    new(...).call
  end

  def initialize(orcid_id:)
    @orcid_id = orcid_id
  end

  def call
    return orcid_result if orcid_result.failure?

    response = Faraday.new.get(url, {}, headers)
    return Failure.new(response.status) unless response.success?

    response_hash = JSON.parse(response.body)
    Success.new([response_hash.dig('name', 'given-names', 'value'), response_hash.dig('name', 'family-name', 'value')])
  end

  private

  attr_reader :orcid_id

  def orcid_result
    @orcid_result ||= begin
      match = /[0-9xX]{4}-[0-9xX]{4}-[0-9xX]{4}-[0-9xX]{4}/.match(orcid_id)
      match ? Success.new(match[0]&.upcase) : Failure.new(400)
    end
  end

  def url
    "#{Settings.orcid.public_api_base_url}#{orcid_result.value!}/personal-details"
  end

  def headers
    {
      'Accept' => 'application/json',
      'User-Agent' => 'Stanford Self-Deposit (Happy Heron)'
    }
  end
end
