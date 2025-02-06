# frozen_string_literal: true

# Looks up data for sunets from the UIT account service
class AccountsController < ApplicationController
  verify_authorized

  def search
    authorize! with: AccountPolicy

    @account = lookup
    render layout: false
  end

  private

  # Does a lookup from the account service in production mode, otherwise examines local database for users
  def lookup
    return AccountService.call(sunetid: params[:id]) if Rails.env.production?

    user = User.find_by(email_address: "#{params[:id]}@stanford.edu")
    return nil unless user

    AccountService::Account.new(name: user.name || user.sunetid,
                                sunetid: user.sunetid,
                                description: 'Digital Library Systems and Services, Digital Library Software Engineer - Web & Infrastructure') # rubocop:disable Layout/LineLength
  end
end
