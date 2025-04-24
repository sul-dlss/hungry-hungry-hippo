# frozen_string_literal: true

# Retrieve names from the account API run by UIT
class AccountService
  class AccountServiceHiccough < StandardError; end

  Account = Struct.new(:sunetid, :name, :description, keyword_init: true)

  def self.call(...)
    new(...).call
  end

  def initialize(sunetid:)
    @sunetid = sunetid
  end

  # @return [Account, nil] the account or nil if not found
  def call
    return if sunetid.blank?
    return if params.blank?

    # Using the sunetid returned from the Account API since it will perform some normalization
    # e.g., removing accidental delimiter characters
    Account.new(sunetid: params['id'], description: params['description'], name:)
  end

  private

  attr_reader :sunetid

  def connection
    Faraday::Connection.new(ssl: {
                              client_cert: cert,
                              client_key: key,
                              verify: false
                            }) do |conn|
      conn.response :json
    end
  end

  def pem_file
    @pem_file ||= File.read(Settings.accountws.pem_file)
  end

  def key
    @@key ||= @key = OpenSSL::PKey.read pem_file # rubocop:disable Style/ClassVars
  end

  def cert
    @@cert ||= OpenSSL::X509::Certificate.new pem_file # rubocop:disable Style/ClassVars
  end

  def name
    # "Last, First" to "First Last"
    params['name'].split(', ').reverse.join(' ')
  end

  def params
    @params ||= Rails.cache.fetch(sunetid, namespace: 'account', expires_in: 1.month) do
      url = "https://#{Settings.accountws.host}/accounts/#{ERB::Util.url_encode(sunetid)}"

      # The account service frequently returns 500 errors. Retry the connection five times in rapid succession.
      begin
        tries ||= 1
        response = connection.get(url)
        # Raise and retry if the response is an HTTP 500.
        #
        # If, on the other hand, a bogus sunetid is provided, the `status` of the response will be 404, and then we:
        #
        # 1. Do *not* want to retry; but
        # 2. *Do* want to cache the empty document
        raise AccountServiceHiccough if response.status == 500

        # Write the user's name and description to the cache, *or* write an
        # empty document to the cache if the response is a 404, as that response
        # has no `name` and `description` keys.
        response.body.slice('name', 'description', 'id')
      rescue AccountServiceHiccough
        retry if (tries += 1) <= 5

        # Prevent writing to the cache of all connection attempts error out
        nil
      end
    end
  end
end
