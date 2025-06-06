# frozen_string_literal: true

module Admin
  # Controller for creating work reports
  class WorkReportController < Admin::ApplicationController
    def new
      authorize!

      @collections = Collection.all
      @work_report_form = Admin::WorkReportForm.new
    end

    def create
      authorize!

      @work_report_form = Admin::WorkReportForm.new(**work_report_params)

      if @work_report_form.valid?
        WorkReportsJob.perform_later(work_report_form: @work_report_form, current_user:)
        flash[:success] = I18n.t('messages.work_report_generated')
        redirect_to new_admin_work_report_path
      else
        @collections = Collection.all
        render :new, status: :unprocessable_entity
      end
    end

    private

    def work_report_params
      params.expect(admin_work_report: [:date_created_start, :date_created_end, :date_modified_start,
                                        :date_modified_end, :last_deposited_start, :last_deposited_end,
                                        :draft_not_deposited_state, :pending_review_state, :returned_state,
                                        :deposit_in_progress_state, :deposited_state, :version_draft_state,
                                        { collection_ids: [] }])
    end
  end
end
