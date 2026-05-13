# frozen_string_literal: true

# Looks up data for sunets from the UIT account service
class AccountsController < ApplicationController
  verify_authorized

  def search
    authorize! with: AccountPolicy

    @account = AccountService.call(id: params[:id])
    return head :not_found if @account.blank?

    respond_to do |format|
      format.html { render layout: false }
      format.json { render json: @account }
    end
  end
end
