# frozen_string_literal: true

# Looks up data for sunets from the UIT account service
class AccountsController < ApplicationController
  verify_authorized

  def search
    authorize! with: AccountPolicy

    @account = lookup_account
    return head :not_found if @account.nil?

    respond_to do |format|
      format.html { render layout: false }
      format.json { render json: @account }
    end
  end

  private

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
