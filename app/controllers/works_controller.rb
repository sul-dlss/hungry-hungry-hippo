# frozen_string_literal: true

# Controller for a Work
class WorksController < ApplicationController
  before_action :check_deposit_job_started, only: %i[show edit]
  before_action :set_work_form_from_cocina, only: %i[show edit]
  before_action :set_status, only: %i[show edit]
  def show
    @status_presenter = StatusPresenter.new(status: @status)
  end

  def new
    @work_form = WorkForm.new

    render :form
  end

  def edit
    unless editable?
      flash[:danger] = I18n.t('works.edit.errors.cannot_be_edited')
      return redirect_to work_path(druid: params[:druid])
    end
    render :form
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @work_form = WorkForm.new(work_params)
    # The deposit param determines whether extra validations for deposits are applied.
    if @work_form.valid?(deposit: deposit?)
      # TODO: Once we have a path from the dashboard, remove this step to create a collection
      collection = Collection.create_or_find_by!(druid: 'druid:cc234dd5678') do |c|
        c.title = 'Temp Collection'
        c.user = current_user
      end

      # Setting the deposit_job_started_at to the current time to indicate that the deposit job has started and user
      # should be "waiting".
      work = Work.create!(title: @work_form.title, user: current_user, deposit_job_started_at: Time.zone.now,
                          collection_id: collection.id)
      DepositJob.perform_later(work:, work_form: @work_form, deposit: deposit?)
      redirect_to wait_works_path(work.id)
    else
      render :form, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize

  def update
    @work_form = WorkForm.new(work_params.merge(druid: params[:druid]))
    # The deposit param determines whether extra validations for deposits are applied.
    if @work_form.valid?(deposit: deposit?)
      work = Work.find_by!(druid: params[:druid])
      DepositJob.perform_later(work:, work_form: @work_form, deposit: deposit?)
      redirect_to wait_works_path(work.id)
    else
      render :form, status: :unprocessable_entity
    end
  end

  def wait
    work = Work.find(params[:id])
    redirect_to work_path(druid: work.druid) if work.deposit_job_finished?
  end

  private

  def work_params
    params.expect(work: %i[title abstract version lock])
  end

  def deposit?
    params[:commit] == 'Deposit'
  end

  def check_deposit_job_started
    work = Work.find_by!(druid: params[:druid])
    redirect_to wait_works_path(work.id) if work.deposit_job_started?
  end

  def set_work_form_from_cocina
    @cocina_object = Sdr::Repository.find(druid: params[:druid])
    @work_form = ToWorkForm::Mapper.call(cocina_object: @cocina_object)
  end

  def set_status
    @status = Sdr::Repository.status(druid: params[:druid])
  end

  def editable?
    return false unless @status.open? || @status.openable?

    ToWorkForm::RoundtripValidator.roundtrippable?(work_form: @work_form, cocina_object: @cocina_object)
  end
end
