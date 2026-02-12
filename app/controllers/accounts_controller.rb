# frozen_string_literal: true

# Looks up data for sunets from the UIT account service
class AccountsController < ApplicationController
  verify_authorized

  def search
    authorize! with: AccountPolicy

    account = lookup_account
    return head :not_found if account.nil?

    render json: account
  end

  def search_user
    authorize! with: AccountPolicy

    @account = lookup_account
    return head :not_found if @account.nil?

    render layout: false
  end

  private

  # Returns the id from the params, either from :id (search) or :sunetid (search_user).
  def id
    @id ||= params[:id] || params[:sunetid]
  end

  # Does a lookup from the account service in production mode, otherwise examines local database for users
  def lookup_account
    return AccountService.call(id:) unless Rails.env.development?

    user = User.find_by_sunetid(sunetid: id) || User.find_by(email_address: id)
    return nil unless user

    AccountService::Account.new(name: user.name || user.sunetid, sunetid: user.sunetid,
                                description: 'Digital Library Systems and Services')
  end
end
