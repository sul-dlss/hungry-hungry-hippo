# frozen_string_literal: true

# Controller for a Work
class WorksController < ApplicationController
  before_action :set_work, only: %i[show edit update destroy]
  before_action :check_deposit_job_started, only: %i[show edit]
  before_action :set_work_form_from_cocina, only: %i[show edit]
  before_action :set_content, only: %i[show edit]
  before_action :set_status, only: %i[show edit destroy]

  def show
    authorize @work

    # This updates the Work with the latest metadata from the Cocina object.
    # Does not update the Work's collection if the collection cannot be found.
    ModelSync::Work.call(work: @work, cocina_object: @cocina_object, raise: false)

    @work_presenter = WorkPresenter.new(work: @work, work_form: @work_form, version_status: @version_status)
  end

  def new
    collection = Collection.find_by!(druid: params.expect(:collection_druid))
    authorize collection, policy_class: WorkPolicy

    @content = Content.create!(user: current_user)
    @work_form = WorkForm.new(collection_druid: collection.druid, content_id: @content.id)

    render :form
  end

  def edit
    authorize @work

    unless editable?
      flash[:danger] = helpers.t('works.edit.messages.cannot_be_edited')
      return redirect_to work_path(druid: params[:druid])
    end

    # This updates the Work with the latest metadata from the Cocina object.
    ModelSync::Work.call(work: @work, cocina_object: @cocina_object)

    render :form
  end

  def create # rubocop:disable Metrics/AbcSize
    @work_form = WorkForm.new(**work_params)
    collection = Collection.find_by!(druid: @work_form.collection_druid)
    authorize collection, policy_class: WorkPolicy

    # The deposit param determines whether extra validations for deposits are applied.
    if @work_form.valid?(deposit: deposit?)
      # Setting the deposit_job_started_at to the current time to indicate that the deposit job has started and user
      # should be "waiting".
      work = Work.create!(title: @work_form.title, user: current_user, deposit_job_started_at: Time.zone.now,
                          collection:)
      DepositWorkJob.perform_later(work:, work_form: @work_form, deposit: deposit?)
      redirect_to wait_works_path(work.id)
    else
      @content = Content.find(@work_form.content_id)
      render :form, status: :unprocessable_entity
    end
  end

  def update
    authorize @work

    @work_form = WorkForm.new(**update_work_params)
    # The deposit param determines whether extra validations for deposits are applied.
    if @work_form.valid?(deposit: deposit?)
      # Setting the deposit_job_started_at to the current time to indicate that the deposit job has started and user
      # should be "waiting".
      @work.update!(deposit_job_started_at: Time.zone.now)
      DepositWorkJob.perform_later(work: @work, work_form: @work_form, deposit: deposit?)
      redirect_to wait_works_path(@work.id)
    else
      @content = Content.find(@work_form.content_id)
      render :form, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @work

    Sdr::Repository.discard_draft(druid: @work.druid)
    flash[:success] = helpers.t('works.edit.messages.draft_discarded')
    # When version 1 SDR will purge the DRO. The Work record can be destroyed as well.
    if @version_status.version == 1
      collection_druid = @work.collection.druid
      @work.destroy!
      redirect_to collection_path(druid: collection_druid)
    else
      redirect_to work_path(druid: @work.druid)
    end
  end

  def wait
    work = Work.find(params[:id])
    authorize work

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
    @version_status = Sdr::Repository.status(druid: params[:druid])
  end

  def set_content
    @content = Contents::Builder.call(cocina_object: @cocina_object, user: current_user)
    @work_form.content_id = @content.id
  end

  def editable?
    return false unless @version_status.editable?

    # This handles the case in which the collection for the work was changed elsewhere
    # and there is not a Collection record for the collection_druid in the work.
    return false unless Collection.exists?(druid: @work_form.collection_druid)

    ToWorkForm::RoundtripValidator.roundtrippable?(work_form: @work_form, cocina_object: @cocina_object,
                                                   content: @content)
  end
end
