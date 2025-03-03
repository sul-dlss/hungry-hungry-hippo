# frozen_string_literal: true

module Admin
  # Controller to allow searching for depositor SUNet IDs given druids
  class DepositorsSearchController < Admin::ApplicationController
    def index
      authorize!

      @depositors_search_form = Admin::DepositorsSearchForm.new(**depositors_search_params)

      if @depositors_search_form.valid?
        @druid_to_depositor_sunetid_map = Admin::DepositorsSearch.call(form: @depositors_search_form)
        render :index, status: :created
      else
        render :new, status: :unprocessable_entity
      end
    end

    def new
      authorize!

      @depositors_search_form = Admin::DepositorsSearchForm.new
    end

    private

    def depositors_search_params
      params.expect(admin_depositors_search: Admin::DepositorsSearchForm.user_editable_attributes)
    end
  end
end
