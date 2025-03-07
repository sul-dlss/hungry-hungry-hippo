# frozen_string_literal: true

# Model for DOIs
class Doi
  def self.id(...)
    new(...).id
  end

  def self.url(...)
    new(...).url
  end

  def self.assigned?(...)
    new(...).assigned?
  end

  def initialize(druid:)
    @druid = druid
  end

  def id
    @id ||= "#{prefix}/#{druid.delete_prefix('druid:')}"
  end

  def url
    @url ||= "https://doi.org/#{id}"
  end

  def assigned?
    @assigned ||= begin
      result = client.exists?(id:) # returns a Dry::Monads result
      Honeybadger.notify("Datacite error for #{druid}: #{result.failure}") if result.failure?
      result.value_or(false)
    end
  end

  private

  attr_reader :druid

  def prefix
    Settings.datacite.prefix
  end

  def client
    Datacite::Client.new(host: Settings.datacite.host)
  end
end
