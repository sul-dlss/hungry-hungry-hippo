# frozen_string_literal: true

module Admin
  # Controller for changing ownership of resources
  class ChangeOwnerController < Admin::ApplicationController
    def new
      authorize!

      @change_owner_form = Admin::ChangeOwnerForm.new(content_id: params[:content_id])
      render :form
    end

    def create
      authorize!

      @change_owner_form = Admin::ChangeOwnerForm.new(work_form:, **change_owner_params)

      if @change_owner_form.valid?
        work_form.content_id = @change_owner_form.content_id
        Admin::ChangeOwner.call(work_form:, work:, owner: @change_owner_form.owner, version_status:)

        render_change_owner_success
      else
        render :form, status: :unprocessable_entity
      end
    end

    private

    def change_owner_params
      params.expect(admin_change_owner: %i[content_id sunetid])
    end

    def work
      @work ||= Work.find_by(druid: params[:work_druid])
    end

    def cocina_object
      @cocina_object ||= Sdr::Repository.find(druid: params[:work_druid])
    end

    def work_form
      @work_form ||= Form::WorkMapper.call(cocina_object:,
                                           doi_assigned: DoiAssignedService.call(cocina_object:, work:),
                                           agree_to_terms: current_user.agree_to_terms?,
                                           version_description: 'Changing ownership',
                                           collection: work.collection)
    end

    def version_status
      @version_status ||= Sdr::Repository.status(druid: params[:work_druid])
    end

    def render_change_owner_success
      flash[:success] = I18n.t('messages.work_changed_owner')
      # This breaks out of the turbo frame.
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.action(:full_page_redirect, wait_works_path(work.id))
        end
      end
    end
  end
end
