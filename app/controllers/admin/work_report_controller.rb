# frozen_string_literal: true

module Admin
  # Controller for creating work reports
  class WorkReportController < Admin::ApplicationController
    def new
      authorize!

      @collections = Collection.pluck(:title, :id)
      @work_report_form = Admin::WorkReportForm.new
      @states = states
    end

    def create
      authorize!

      @work_report_form = Admin::WorkReportForm.new(**work_report_params)
      # If the form is submitted, provide a confirmation
      if @work_report_form.valid?
        Admin::WorkReport.call(work_report_form: @work_report_form)
        flash[:success] = I18n.t('messages.work_report_generated')
        redirect_to new_admin_work_report_path
      else
        @collections = Collection.pluck(:title, :id)
        @states = states
        render :new, status: :unprocessable_entity
      end
    end

    private

    def work_report_params
      params.permit(:date_created_start)
    end

    def states
      [['Draft - not deposited', 'draft'], ['Pending approval', 'pending_approval'],
       ['Returned', 'returned'], ['Deposit in progress', 'deposit-in_progress'], ['Deposited', 'deposited'],
       ['New version in draft', 'new_version_in_draft']]
    end
  end
end
