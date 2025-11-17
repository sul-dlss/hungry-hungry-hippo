# frozen_string_literal: true

module Admin
  # Controller for deleting a work as an administrator
  class DeleteWorkController < Admin::ApplicationController
    def new
      authorize!

      render :form
    end

    def destroy
      authorize!

      work.destroy!
      render_delete_success
    end

    attr_reader :work_form

    private

    def work
      return @work if defined?(@work)

      @work = Work.find_by(druid: params[:druid])
    end

    def render_delete_success
      flash[:success] = I18n.t('messages.work_deleted')
      # This breaks out of the turbo frame.
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.action(:full_page_redirect, dashboard_path)
        end
      end
    end
  end
end
