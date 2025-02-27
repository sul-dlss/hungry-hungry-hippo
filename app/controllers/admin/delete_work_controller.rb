# frozen_string_literal: true

module Admin
  # Controller for deleting a work as an administrator
  class DeleteWorkController < Admin::ApplicationController
    def new
      authorize!

      @delete_form = Admin::DeleteForm.new
      render :form
    end

    def create
      authorize!

      @delete_form = Admin::DeleteForm.new(work_form:)
      if @delete_form.valid?
        Admin::DeleteWork.call(work_form:, work:)
        render_delete_success
      else
        render :form, status: :unprocessable_entity
      end
    end

    private

    def work
      @work ||= Work.find_by(druid: params[:work_druid])
    end

    def cocina_object
      @cocina_object ||= Sdr::Repository.find(druid: params[:work_druid])
    end

    def work_form
      @work_form ||= ToWorkForm::Mapper.call(cocina_object:,
                                             doi_assigned: DoiAssignedService.call(cocina_object:, work:),
                                             agree_to_terms: current_user.agree_to_terms?,
                                             version_description: 'Deleting')
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
