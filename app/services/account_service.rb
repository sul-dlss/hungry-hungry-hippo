# frozen_string_literal: true

# Retrieve names from the account API run by UIT
class AccountService
  Account = Struct.new(:sunetid, :name, :description)

  # Fake the MAIS Person API client. Used for development environments
  class FakeMaisPersonClient
    Person = Struct.new(:sunetid, :name, :description)

    def self.fetch_user(id)
      user = User.find_by_sunetid(sunetid: id) ||
             User.find_by_sunetid(sunetid: id.downcase) ||
             User.find_by(email_address: id) ||
             User.find_by(email_address: id.downcase)
      return if user.nil?

      {
        name: user.name || user.sunetid,
        sunetid: user.sunetid,
        description: 'Digital Library Systems and Services'
      }
    end

    def self.to_person(user_hash)
      Person.new(**user_hash)
    end
  end

  def self.call(...)
    new(...).call
  end

  # @param id [String] the SUNet ID or email of the account to look up
  def initialize(id:)
    @id = id&.delete_suffix('@stanford.edu')
  end

  # @return [Account, nil] the account or nil if not found
  def call
    return if id.blank? || account_attributes.blank?

    # Using the sunetid returned from the Account API since it will perform some normalization
    # e.g., removing accidental delimiter characters
    Account.new(**account_attributes)
  end

  private

  attr_reader :id

  def account_attributes
    @account_attributes ||= Rails.cache.fetch(id, namespace: 'account', expires_in: 1.month) { person.to_h }
  end

  def person
    result = client_class.fetch_user(id)
    return if result.nil?

    client_class.to_person(result)
  end

  # NOTE: Both the real and fake clients have the same interface, so we can use
  #       the same code to call them and just swap out the class based on the
  #       environment. To achieve this, the real client is monkeypatched in an
  #       initializer to add the same methods as the fake client, so that the
  #       AccountService can call the same methods regardless of which client is
  #       being used.
  def client_class
    return FakeMaisPersonClient if Rails.env.development?

    MaisPersonClient
  end
end
