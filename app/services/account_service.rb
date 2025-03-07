# frozen_string_literal: true

# Retrieve names from the account API run by UIT
class AccountService
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
    return if params.empty?

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
      response = connection.get(url)
      doc = response.body
      doc.slice('name', 'description', 'id')
    end
  end
end
