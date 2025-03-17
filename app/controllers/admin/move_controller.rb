# frozen_string_literal: true

module Admin
  # Controller for moving resources between collections
  class MoveController < Admin::ApplicationController
    def new
      authorize!

      @move_form = Admin::MoveForm.new(content_id: params[:content_id])
      render :form
    end

    def create
      authorize!

      @move_form = Admin::MoveForm.new(work_form:, **move_params)

      if @move_form.valid?
        work_form.content_id = @move_form.content_id
        Admin::Move.call(work_form:, work:, collection: @move_form.collection, version_status:)

        render_move_success
      else
        render :form, status: :unprocessable_entity
      end
    end

    private

    def move_params
      params.expect(admin_move: %i[content_id collection_druid])
    end

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
                                             version_description: 'Moving collection',
                                             collection: work.collection)
    end

    def version_status
      @version_status ||= Sdr::Repository.status(druid: params[:work_druid])
    end

    def render_move_success
      flash[:success] = I18n.t('messages.work_moved')
      # This breaks out of the turbo frame.
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.action(:full_page_redirect, wait_works_path(work.id))
        end
      end
    end
  end
end
