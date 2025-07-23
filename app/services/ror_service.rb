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

    # limit the data we get from the RoR API and map to our model object for display
    results['items'].map { |org| Org.new(org.slice('id', 'name', 'aliases', 'addresses', 'country', 'types')) }
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

  # Data model for a RoR organization, allows us to map the data returned by the RoR API into fields we use for display
  class Org
    attr_accessor :id, :name, :city, :country, :aliases, :org_types

    def initialize(data)
      @id = data['id']
      @name = data['name']
      @city = data['addresses']&.first&.dig('city')
      @country = data.dig('country', 'country_name')
      # some orgs have lots of aliases (eg. https://ror.org/02vzbm991), limit aliases to 3 to keep it sane for display
      @aliases = data['aliases']&.first(3)&.join(', ')
      @org_types = data['types']&.join(', ')
    end

    def location
      [city, country].compact.join(', ')
    end
  end
end
