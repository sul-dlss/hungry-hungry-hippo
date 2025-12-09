# frozen_string_literal: true

module Admin
  # Controller to allow searching for depositor SUNet IDs given druids
  class DepositorsSearchController < Admin::ApplicationController
    def new
      authorize!

      @depositors_search_form = Admin::DepositorsSearchForm.new

      render :search
    end

    def search
      authorize!

      @depositors_search_form = Admin::DepositorsSearchForm.new(**depositors_search_params)

      if @depositors_search_form.valid?
        @druid_to_sunetid_map = Admin::DepositorsSearch.call(form: @depositors_search_form)
      else
        render :search, status: :unprocessable_content
      end
    end

    private

    def depositors_search_params
      params.expect(admin_depositors_search: Admin::DepositorsSearchForm.permitted_params)
    end
  end
end
