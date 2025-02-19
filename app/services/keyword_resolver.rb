# frozen_string_literal: true

# Resolve keyword query strings onto authorities
class KeywordResolver
  include Dry::Monads[:result]

  # @see KeywordResolver#initialize, KeywordResolver#call
  def self.call(...)
    new(...).call
  end

  # @param [String] query a query string for the keyword resolver service
  def initialize(query:)
    @query = query
  end

  # @return [Dry::Monads::Result] a monad result, either a failure or a success
  def call
    result = resolve(query)
    return result if result.failure?

    Success(result.value!)
  end

  private

  attr_reader :query

  def connection
    @connection ||= Faraday.new(
      url: Settings.autocomplete_lookup.url,
      headers: {
        'Accept' => 'application/json',
        'User-Agent' => 'Stanford Self-Deposit (Hungry Hungry Hippo)'
      }
    )
  end

  # Map of FAST tag types to Cocina types.
  TAG_TYPES = {
    100 => 'person',
    110 => 'organization',
    111 => 'conference',
    130 => 'title',
    147 => 'event',
    148 => 'time',
    151 => 'place',
    155 => 'genre'
  }.freeze
  private_constant :TAG_TYPES

  def parse(body)
    JSON.parse(body).dig('response', 'docs').map do |result|
      {
        result['suggestall'].first => "#{Settings.autocomplete_lookup.identifier_prefix}" \
                                      "#{result['idroot'].first.delete_prefix('fst').to_i}/::" \
                                      "#{TAG_TYPES.fetch(result['tag'], 'topic')}"
      }
    end
  end

  def resolve(query) # rubocop:disable Metrics/AbcSize
    response = connection.get do |req|
      req.params['query'] = query
      req.params['queryIndex'] = 'suggestall'
      req.params['queryReturn'] = 'idroot,suggestall,tag'
      req.params['suggest'] = 'autoSubject'
      # Requesting extra records to try to increase the likelihood that get left anchored matches
      # since results are sorted by usage.
      req.params['rows'] = Settings.autocomplete_lookup.num_records * 2
      req.params['sort'] = 'usage desc'
    end

    return Success(parse(response.body)) if response.success?

    Honeybadger.notify('FAST API Error', context: { query:, response: })
    Failure("Autocomplete results for #{query} returned #{response.status}")
  end
end
