# frozen_string_literal: true

module Admin
  # Controller for moving resources between collections
  class MoveController < Admin::ApplicationController
    before_action :set_work
    before_action :set_status
    before_action :set_work_form_from_cocina

    def new
      authorize!

      @collections = Admin::MoveTargetCollections.call(work_form: @work_form)
    end

    def create
      authorize!

      collection = Collection.find_by(druid: params[:collection_druid])
      Admin::Move.call(work_form: @work_form, work: @work, collection:, version_status: @version_status)

      flash[:success] = I18n.t('messages.work_moved')
      redirect_to wait_works_path(@work.id)
    end

    private

    def set_work
      @work = Work.find_by(druid: params[:work_druid])
    end

    def set_work_form_from_cocina
      @cocina_object = Sdr::Repository.find(druid: params[:work_druid])
      @work_form = ToWorkForm::Mapper.call(cocina_object: @cocina_object,
                                           doi_assigned: DoiAssignedService.call(cocina_object: @cocina_object,
                                                                                 work: @work),
                                           agree_to_terms: current_user.agree_to_terms?,
                                           version_description: 'Moving collection')
      @work_form.content_id = params[:content_id]
    end

    def set_status
      @version_status = Sdr::Repository.status(druid: params[:work_druid])
    end
  end
end
