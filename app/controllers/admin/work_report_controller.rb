# frozen_string_literal: true

module Admin
  # Controller for creating work reports
  class WorkReportController < Admin::ApplicationController
    def new
      authorize!

      @work_report_form = if params[:commit]
                            Admin::WorkReportForm.new(**work_report_params)
                            # If the form is submitted, provide a confirmation
                            # do query and email the results
                          else
                            Admin::WorkReportForm.new
                          end
    end

    private

    def work_report_params
      # params.permit(:date_created_start)
    end
  end
end
