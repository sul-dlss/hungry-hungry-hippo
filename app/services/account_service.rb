# frozen_string_literal: true

# Retrieve names from the account API run by UIT
class AccountService
  Account = Struct.new(:sunetid, :name, :description, keyword_init: true)

  def self.call(...)
    new(...).call
  end

  # @param id [String] the SUNetID or email of the account to look up
  def initialize(id:)
    @id = id&.delete_suffix('@stanford.edu')
  end

  # @return [Account, nil] the account or nil if not found
  def call
    return if id.blank?
    return if params.blank?

    # Using the sunetid returned from the Account API since it will perform some normalization
    # e.g., removing accidental delimiter characters
    Account.new(**params)
  end

  private

  attr_reader :id

  def params # rubocop:disable Metrics/AbcSize
    @params ||= Rails.cache.fetch(id, namespace: 'account', expires_in: 1.month) do
      result = MaisPersonClient.fetch_user(id.downcase)
      result ||= MaisPersonClient.fetch_user(id) if id.downcase != id
      if result
        person = MaisPersonClient::Person.new(result)
        {
          sunetid: person.sunetid,
          name: [person.display_name.first_name, person.display_name.last].compact.join(' '),
          description: person.job_title
        }
      else
        {}
      end
    end
  end
end
