# frozen_string_literal: true

module Importers
  # Imports a user from a JSON export from H2.
  class User
    def self.call(...)
      new(...).call
    end

    def initialize(user_json:)
      @user_json = user_json
    end

    def call
      ::User.find_or_create_by!(email_address: user_json['email']) do |user|
        user.name = user_json['name'] || user_json['email'].delete_suffix(::User::EMAIL_SUFFIX)
        user.first_name = user_json['first_name']
      end
    end

    private

    attr_reader :user_json
  end
end
