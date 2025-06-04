# frozen_string_literal: true

module Admin
  # Controller for creating work reports
  class WorkReportController < Admin::ApplicationController
    def new
      authorize!

      @collections = Collection.pluck(:title, :id)
      @work_report_form = Admin::WorkReportForm.new
    end

    def create
      authorize!

      @work_report_form = Admin::WorkReportForm.new(**work_report_params)
      if @work_report_form.valid?
        Admin::WorkReport.call(work_report_form: @work_report_form)
        flash[:success] = I18n.t('messages.work_report_generated')
        redirect_to new_admin_work_report_path
      else
        @collections = Collection.pluck(:title, :id)
        render :new, status: :unprocessable_entity
      end
    end

    private

    def work_report_params
      params.expect(:admin_work_report)
    end
  end
end
