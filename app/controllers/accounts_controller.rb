# frozen_string_literal: true

# Looks up data for sunets from the UIT account service
class AccountsController < ApplicationController
  verify_authorized

  def search
    authorize! with: AccountPolicy

    @account = lookup_account
    render layout: false
  end

  private

  # Does a lookup from the account service in production mode, otherwise examines local database for users
  def lookup_account
    return AccountService.call(sunetid: params[:id]) unless Rails.env.development?

    user = User.find_by_sunetid(sunetid: params[:id])
    return nil unless user

    AccountService::Account.new(name: user.name || user.sunetid, sunetid: user.sunetid,
                                description: 'Digital Library Systems and Services')
  end
end
