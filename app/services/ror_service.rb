# frozen_string_literal: true

# Class for ROR support
class RorService
  def self.organizations(query:)
    organizations = new.query(path: '/organizations', params: { query: })
    return [] if organizations['number_of_results'].to_i.zero?

    organizations['items'].map { |org| org.slice('id', 'name') }
  end

  def initialize
    @conn = new_conn
  end

  attr_reader :conn

  def query(path:, params: {})
    conn.get(path, params.compact, headers).body
  rescue Faraday::Error => e
    raise Error, "Connection err: #{e.message}"
  rescue JSON::ParserError => e
    raise Error, "JSON parsing error: #{e.message}"
  end

  private

  def new_conn
    Faraday.new({ url: Settings.ror.url }.compact) do |f|
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

end
