# frozen_string_literal: true

# Controller for a Collection
class CollectionsController < ApplicationController
  before_action :set_collection, only: %i[show edit update works history]
  before_action :check_deposit_registering_or_updating, only: %i[show edit]
  before_action :set_collection_form_from_cocina, only: %i[show edit]
  before_action :set_status, only: %i[show edit]
  before_action :set_presenter, only: %i[show edit]

  def show
    authorize! @collection

    # This updates the Collection with the latest metadata from the Cocina object.
    CollectionModelSynchronizer.call(collection: @collection, cocina_object: @cocina_object)
  end

  def new
    authorize! Collection
    @collection_form = CollectionForm.new(
      managers_attributes: [{ sunetid: current_user.sunetid, name: current_user.name }],
      contact_emails_attributes: [{ email: current_user.email_address }],
      # This gets rid of the default empty nested forms.
      reviewers_attributes: [],
      depositors_attributes: []
    )

    render :form
  end

  def edit
    authorize! @collection

    unless editable?
      flash[:danger] = I18n.t('collections.edit.messages.cannot_be_edited')
      return redirect_to collection_path(params[:druid])
    end

    # This updates the Collection with the latest metadata from the Cocina object.
    CollectionModelSynchronizer.call(collection: @collection, cocina_object: @cocina_object)

    render :form
  end

  def create
    authorize! Collection
    @collection_form = CollectionForm.new(**collection_params)
    if (@valid = @collection_form.valid?(:deposit))
      collection = Collection.create!(title: @collection_form.title,
                                      user: current_user,
                                      deposit_state_event: 'deposit_persist')
      DepositCollectionJob.perform_later(collection:, collection_form: @collection_form, current_user:)
      redirect_to wait_collections_path(collection.id)
    else
      add_blank_contributor
      render :form, status: :unprocessable_entity
    end
  end

  def update
    authorize! @collection

    @collection_form = CollectionForm.new(**update_collection_params)
    # The validation_context param determines whether extra validations are applied, e.g., for deposits.
    if (@valid = @collection_form.valid?(:deposit))
      @collection.deposit_persist! # Sets the deposit state
      DepositCollectionJob.perform_later(collection: @collection, collection_form: @collection_form, current_user:)
      redirect_to wait_collections_path(@collection.id)
    else
      add_blank_contributor
      render :form, status: :unprocessable_entity
    end
  end

  def wait
    @collection = Collection.find(params[:id])
    authorize! @collection

    redirect_to collection_path(@collection) unless @collection.deposit_registering_or_updating?
  end

  def works
    authorize! @collection

    @search_term = params[:q]
    works = authorized_scope(collection_works_result, as: :collection,
                                                      scope_options: { collection: @collection }).joins(:user)
    @presenters = WorkSortService.call(works:, sort_by:, page: params[:page])
  end

  def sort_by
    params[:sort_by] || 'works.object_updated_at desc'
  end

  def history
    authorize! @collection

    @events = Sdr::Event.list(druid: @collection.druid).map { |event| EventPresenter.new(event:) }

    # The history table is the same for works and collections.
    render 'works/history', layout: false
  end

  private

  # @return [ActiveRecord::Relation] the works to display for the collection, filtered by search term if applicable
  def collection_works_result
    return @collection.works if @search_term.blank?

    @collection.works.joins(
      :user
    ).where('title ILIKE ?', "%#{@search_term}%").or(
      @collection.works.where('druid ILIKE ?', "%#{@search_term}%")
    ).or(
      # no need to search first_name: it seems like name always contains it. e.g. as of
      # june 2025, User.where('name !~* first_name').count returned 0.
      @collection.works.joins(:user).where('name ILIKE ?', "%#{@search_term}%")
    )
  end

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
    @collection_form = Form::CollectionMapper.call(cocina_object: @cocina_object, collection: @collection)
  end

  def set_status
    @version_status = Sdr::Repository.status(druid: params[:druid])
  end

  def editable?
    return false unless @version_status.editable?

    CollectionRoundtripper.call(collection_form: @collection_form,
                                cocina_object: @cocina_object)
  end

  def set_presenter
    @collection_presenter = CollectionPresenter.new(collection: @collection, collection_form: @collection_form,
                                                    version_status: @version_status)
  end

  def add_blank_contributor
    @collection_form.contributors_attributes = [{}] if @collection_form.contributors_attributes.empty?
  end
end
