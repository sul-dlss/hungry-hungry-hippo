# frozen_string_literal: true

# Controller for a Collection
class CollectionsController < ApplicationController
  before_action :set_collection, only: %i[show edit update destroy]
  before_action :check_deposit_job_started, only: %i[show edit]
  before_action :set_collection_form_from_cocina, only: %i[show edit]
  before_action :set_status, only: %i[show edit destroy]
  before_action :set_presenter, only: %i[show edit]

  def show
    authorize! @collection

    # This updates the Collection with the latest metadata from the Cocina object.
    ModelSync::Collection.call(collection: @collection, cocina_object: @cocina_object)
  end

  def new
    authorize! Collection
    @collection_form = CollectionForm.new

    render :form
  end

  def edit
    authorize! @collection

    unless editable?
      flash[:danger] = I18n.t('collections.edit.messages.cannot_be_edited')
      return redirect_to collection_path(druid: params[:druid])
    end

    # This updates the Collection with the latest metadata from the Cocina object.
    ModelSync::Collection.call(collection: @collection, cocina_object: @cocina_object)

    render :form
  end

  def create
    authorize! Collection
    @collection_form = CollectionForm.new(**collection_params)
    # The deposit param determines whether extra validations for deposits are applied.
    if @collection_form.valid?(deposit: deposit?)
      # Setting the deposit_job_started_at to the current time to indicate that the deposit job has started and user
      # should be "waiting".
      collection = Collection.create!(title: @collection_form.title,
                                      user: current_user,
                                      deposit_job_started_at: Time.zone.now)
      DepositCollectionJob.perform_later(collection:, collection_form: @collection_form, deposit: deposit?)
      redirect_to wait_collections_path(collection.id)
    else
      render :form, status: :unprocessable_entity
    end
  end

  def update
    authorize! @collection

    @collection_form = CollectionForm.new(**update_collection_params)
    # The deposit param determines whether extra validations for deposits are applied.
    if @collection_form.valid?(deposit: deposit?)
      # Setting the deposit_job_started_at to the current time to indicate that the deposit job has started and user
      # should be "waiting".
      @collection.update!(deposit_job_started_at: Time.zone.now)
      DepositCollectionJob.perform_later(collection: @collection, collection_form: @collection_form, deposit: deposit?)
      redirect_to wait_collections_path(@collection.id)
    else
      render :form, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! @collection

    Sdr::Repository.discard_draft(druid: @collection.druid)
    flash[:success] = helpers.t('messages.draft_discarded')
    # When version 1 SDR will purge the DRO. The Collection record can be destroyed as well.
    if @version_status.version == 1
      @collection.destroy!
      redirect_to root_path
    else
      redirect_to collection_path(druid: @collection.druid)
    end
  end

  def wait
    collection = Collection.find(params[:id])
    authorize! collection

    redirect_to collection_path(druid: collection.druid) if collection.deposit_job_finished?
  end

  private

  def collection_params
    params.expect(collection: CollectionForm.user_editable_attributes + [CollectionForm.nested_attributes])
  end

  def update_collection_params
    collection_params.merge(druid: params[:druid])
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
    @version_status = Sdr::Repository.status(druid: params[:druid])
  end

  def editable?
    return false unless @version_status.editable?

    ToCollectionForm::RoundtripValidator.roundtrippable?(collection_form: @collection_form,
                                                         cocina_object: @cocina_object)
  end

  def set_presenter
    @collection_presenter = CollectionPresenter.new(collection: @collection, collection_form: @collection_form,
                                                    version_status: @version_status)
  end
end
