# frozen_string_literal: true

# Class for ROR support
class RorService
  def self.call(...)
    new(...).call
  end

  def initialize(search:)
    @search = search
    @conn = new_conn
  end

  def call
    results = organizations
    return [] if results['number_of_results'].to_i.zero?

    results['items'].map { |org| RorOrg.new(org.slice('id', 'name', 'aliases', 'addresses', 'country', 'types')) }
  end

  attr_reader :conn, :search

  private

  def organizations
    conn.get('/organizations', params, headers).body
  rescue Faraday::Error => e
    raise Error, "Connection err: #{e.message}"
  end

  def new_conn
    Faraday.new({ url: Settings.ror.url }) do |f|
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
    { query: search }
  end
end
