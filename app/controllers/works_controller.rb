# frozen_string_literal: true

# Controller for a Work
class WorksController < ApplicationController
  def show
    work = Work.find_by!(druid: params[:druid])
    return redirect_to wait_works_path(work.id) if work.deposit_job_started?

    cocina_object = Sdr::Repository.find(druid: params[:druid])
    @work_form = ToWorkForm::Mapper.call(cocina_object:)
  end

  def new
    @work_form = WorkForm.new
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @work_form = WorkForm.new(work_params)
    # The deposit param determines whether extra validations for deposits are applied.
    if @work_form.valid?
      # TODO: Once we have a path from the dashboard, remove this step to create a collection
      collection = Collection.create!(title: 'Temp Collection', druid: 'druid:cc234dd5678', user: current_user)
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

  def wait
    work = Work.find(params[:id])
    redirect_to work_path(druid: work.druid) if work.deposit_job_finished?
  end

  private

  def work_params
    params.expect(work: [:title])
  end

  def deposit?
    params[:commit] == 'Deposit'
  end
end
