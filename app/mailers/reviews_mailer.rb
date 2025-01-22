# frozen_string_literal: true

# Sends email notifications about reviews
class ReviewsMailer < ApplicationMailer
  before_action :set_work
  before_action :set_work_presenter, only: [:approved_email]

  def submitted_email
    mail(to: @user.email_address, subject: 'Your deposit is submitted and waiting for approval')
  end

  def rejected_email
    mail(to: @user.email_address, subject: 'Your deposit has been reviewed and returned')
  end

  def approved_email
    mail(to: @user.email_address, subject: 'Your deposit has been reviewed and approved')
  end

  def pending_email
    @user = params[:user]
    mail(to: @user.email_address, subject: "Item ready for review in the #{@collection.title} collection")
  end

  private

  def set_work
    @work = params[:work]
    @user = @work.user
    @collection = @work.collection
  end

  def set_work_presenter
    cocina_object = Sdr::Repository.find(druid: @work.druid)
    version_status = Sdr::Repository.status(druid: @work.druid)
    doi_assigned = DoiAssignedService.call(cocina_object:, work: @work)
    work_form = ToWorkForm::Mapper.call(cocina_object:, doi_assigned:, agree_to_terms: true)
    @work_presenter = WorkPresenter.new(work: @work, work_form:, version_status:)
  end

  def doi_assigned?
    DoiAssignedService.call(cocina_object: @cocina_object, work: @work)
  end
end
