# frozen_string_literal: true

module Admin
  # Controller for creating collection reports
  class CollectionReportController < Admin::ApplicationController
    def new
      authorize!

      @collection_report_form = Admin::CollectionReportForm.new
    end

    def create
      authorize!

      @collection_report_form = Admin::CollectionReportForm.new(**collection_report_params)

      CollectionReportsJob.perform_later(collection_report_form: @collection_report_form, current_user:)
      flash[:success] = I18n.t('messages.collection_report_generated')
      redirect_to new_admin_collection_report_path
    end

    private

    def collection_report_params
      params.expect(admin_collection_report: %i[date_created_start date_created_end
                                                date_modified_start date_modified_end])
    end
  end
end
