# frozen_string_literal: true

# Controller for a Work
class WorksController < ApplicationController
  before_action :set_work, only: %i[show edit update]
  before_action :check_deposit_job_started, only: %i[show edit]
  before_action :set_work_form_from_cocina, only: %i[show edit]
  before_action :set_content, only: %i[show edit]
  before_action :set_status, only: %i[show edit]

  def show
    authorize! @work
    @status_presenter = StatusPresenter.new(status: @status)
  end

  def new
    # Once collection is being passed, should authorize that the user can create a work in that collection.
    skip_verify_authorized!

    @content = Content.create!(user: current_user)
    @work_form = WorkForm.new(collection_druid: params.expect(:collection_druid), content_id: @content.id)

    render :form
  end

  def edit
    authorize! @work

    unless editable?
      flash[:danger] = I18n.t('works.edit.errors.cannot_be_edited')
      return redirect_to work_path(druid: params[:druid])
    end
    render :form
  end

  # rubocop:disable Metrics/AbcSize
  def create
    # Once collection is being passed, should authorize that the user can create a work in that collection.
    skip_verify_authorized!

    @work_form = WorkForm.new(**work_params)
    # The deposit param determines whether extra validations for deposits are applied.
    if @work_form.valid?(deposit: deposit?)
      # Setting the deposit_job_started_at to the current time to indicate that the deposit job has started and user
      # should be "waiting".
      collection = Collection.find_by!(druid: @work_form.collection_druid)
      work = Work.create!(title: @work_form.title, user: current_user, deposit_job_started_at: Time.zone.now,
                          collection: collection)
      DepositWorkJob.perform_later(work:, work_form: @work_form, deposit: deposit?)
      redirect_to wait_works_path(work.id)
    else
      @content = Content.find(@work_form.content_id)
      render :form, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize

  def update
    authorize! @work

    @work_form = WorkForm.new(**update_work_params)
    # The deposit param determines whether extra validations for deposits are applied.
    if @work_form.valid?(deposit: deposit?)
      DepositWorkJob.perform_later(work: @work, work_form: @work_form, deposit: deposit?)
      redirect_to wait_works_path(@work.id)
    else
      @content = Content.find(@work_form.content_id)
      render :form, status: :unprocessable_entity
    end
  end

  def wait
    work = Work.find(params[:id])
    authorize! work

    redirect_to work_path(druid: work.druid) if work.deposit_job_finished?
  end

  private

  def work_params
    params.expect(work: WorkForm.user_editable_attributes + [WorkForm.nested_attributes])
  end

  def update_work_params
    work_params.merge(druid: params[:druid])
  end

  def deposit?
    params[:commit] == 'Deposit'
  end

  def set_work
    @work = Work.find_by!(druid: params[:druid])
  end

  def check_deposit_job_started
    redirect_to wait_works_path(@work.id) if @work.deposit_job_started?
  end

  def set_work_form_from_cocina
    @cocina_object = Sdr::Repository.find(druid: params[:druid])
    @work_form = ToWorkForm::Mapper.call(cocina_object: @cocina_object)
  end

  def set_status
    @status = Sdr::Repository.status(druid: params[:druid])
  end

  def set_content
    @content = Contents::Builder.call(cocina_object: @cocina_object, user: current_user)
    @work_form.content_id = @content.id
  end

  def editable?
    return false unless @status.open? || @status.openable?

    ToWorkForm::RoundtripValidator.roundtrippable?(work_form: @work_form, cocina_object: @cocina_object,
                                                   content: @content)
  end
end
