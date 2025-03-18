# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@sdr.stanford.edu'
  layout 'mailer'

  def set_work
    @work = params[:work]
    @user = @work.user
    @collection = @work.collection
  end

  def set_work_presenter
    cocina_object = Sdr::Repository.find(druid: @work.druid)
    version_status = Sdr::Repository.status(druid: @work.druid)
    doi_assigned = DoiAssignedService.call(cocina_object:, work: @work)
    work_form = ToWorkForm::Mapper.call(cocina_object:, doi_assigned:, agree_to_terms: true,
                                        version_description: version_status.version_description,
                                        collection: @collection)
    @work_presenter = WorkPresenter.new(work: @work, work_form:, version_status:)
  end
end
