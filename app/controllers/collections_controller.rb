# frozen_string_literal: true

# Controller for a Collection
class CollectionsController < ApplicationController
  before_action :set_collection, only: %i[show edit update destroy]
  before_action :check_deposit_registering_or_updating, only: %i[show edit]
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
    @collection_form = CollectionForm.new(managers_attributes: [{ sunetid: current_user.sunetid }, {}])

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

  # rubocop:disable Metrics/AbcSize
  def create
    authorize! Collection
    @collection_form = CollectionForm.new(**collection_params)
    # The validation_context param determines whether extra validations are applied, e.g., for deposits.
    if @collection_form.valid?(validation_context)
      collection = Collection.create!(title: @collection_form.title,
                                      release_option: @collection_form.release_option,
                                      release_duration: @collection_form.release_duration,
                                      access: @collection_form.access,
                                      doi_option: @collection_form.doi_option,
                                      user: current_user,
                                      deposit_state_event: 'deposit_persist')
      DepositCollectionJob.perform_later(collection:, collection_form: @collection_form, deposit: deposit?)
      redirect_to wait_collections_path(collection.id)
    else
      render :form, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize

  def update
    authorize! @collection

    @collection_form = CollectionForm.new(**update_collection_params)
    # The validation_context param determines whether extra validations are applied, e.g., for deposits.
    if @collection_form.valid?(validation_context)
      @collection.deposit_persist! # Sets the deposit state
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

    redirect_to collection_path(druid: collection.druid) unless collection.deposit_registering_or_updating?
  end

  private

  def collection_params
    params.expect(collection: CollectionForm.user_editable_attributes + [CollectionForm.nested_attributes])
  end

  def update_collection_params
    collection_params.merge(druid: params[:druid])
  end

  def set_collection
    @collection = Collection.find_by!(druid: params[:druid])
  end

  def check_deposit_registering_or_updating
    redirect_to wait_collections_path(@collection.id) if @collection.deposit_registering_or_updating?
  end

  def set_collection_form_from_cocina
    @cocina_object = Sdr::Repository.find(druid: params[:druid])
    @collection_form = ToCollectionForm::Mapper.call(cocina_object: @cocina_object, collection: @collection)
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
                                                    version_status: @version_status, work_statuses:)
  end

  def work_statuses
    @work_statuses ||= Sdr::Repository.statuses(
      druids: @collection.works.where.not(druid: nil).pluck(:druid)
    )
  end
end
