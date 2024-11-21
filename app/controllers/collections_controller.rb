# frozen_string_literal: true

# Controller for a Collection
class CollectionsController < ApplicationController
  before_action :set_collection, only: %i[show edit update]
  before_action :check_deposit_job_started, only: %i[show edit]
  before_action :set_collection_form_from_cocina, only: %i[show edit]
  before_action :set_status, only: %i[show edit]

  def show
    authorize! @collection
    @status_presenter = StatusPresenter.new(status: @status)
  end

  def new
    # TODO: Verify any user should be able to create a collection.
    skip_verify_authorized!

    @collection_form = CollectionForm.new

    render :form
  end

  def edit
    authorize! @collection

    unless editable?
      flash[:danger] = I18n.t('works.edit.errors.cannot_be_edited')
      return redirect_to work_path(druid: params[:druid])
    end
    render :form
  end

  # # rubocop:disable Metrics/AbcSize
  def create
    # TODO: Verify any user should be able to create a collection.
    skip_verify_authorized!

    @collection_form = CollectionForm.new(collection_params)
    # The deposit param determines whether extra validations for deposits are applied.
    if @collection_form.valid?(deposit: deposit?)
      # Setting the deposit_job_started_at to the current time to indicate that the deposit job has started and user
      # should be "waiting".
      collection = Collection.create!(title: @collection_form.title, user: current_user, deposit_job_started_at: Time.zone.now)
      DepositCollectionJob.perform_later(collection:, collection_form: @collection_form, deposit: deposit?)
      redirect_to wait_collections_path(collection.id)
    else
      render :form, status: :unprocessable_entity
    end
  end
  # # rubocop:enable Metrics/AbcSize

  def update
    authorize! @collection

    @collection_form = CollectionForm.new(collection_params.merge(druid: params[:druid]))
    # The deposit param determines whether extra validations for deposits are applied.
    if @collection_form.valid?(deposit: deposit?)
      DepositCollectionJob.perform_later(collection: @collection, collection_form: @collection_form, deposit: deposit?)
      redirect_to wait_collections_path(@collection.id)
    else
      render :form, status: :unprocessable_entity
    end
  end

  def wait
    collection = Collection.find(params[:id])
    authorize! collection

    redirect_to collection_path(druid: collection.druid) if collection.deposit_job_finished?
  end

  private

  def collection_params
    params.expect(collection: CollectionForm.user_editable_attributes + [CollectionForm.nested_attributes_hash])
  end

  def deposit?
    params[:commit] == 'Deposit'
  end

  def set_collection
    @collection = Collection.find_by!(druid: params[:druid])
  end

  def check_deposit_job_started
    redirect_to wait_collections_path(@collection.id) if @collection.deposit_job_started?
  end

  def set_collection_form_from_cocina
    @cocina_object = Sdr::Repository.find(druid: params[:druid])
    @collection_form = ToCollectionForm::Mapper.call(cocina_object: @cocina_object)
  end

  def set_status
    @status = Sdr::Repository.status(druid: params[:druid])
  end

  def editable?
    return false unless @status.open? || @status.openable?

    ToCollectionForm::RoundtripValidator.roundtrippable?(collection_form: @collection_form, cocina_object: @cocina_object)
  end
end
