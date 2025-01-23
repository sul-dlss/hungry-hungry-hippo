# frozen_string_literal: true

# Controller for a Work
class WorksController < ApplicationController
  before_action :set_work, only: %i[show edit update destroy review]
  before_action :check_deposit_persisting, only: %i[show edit]
  before_action :set_work_form_from_cocina, only: %i[show edit review]
  before_action :set_content, only: %i[show edit review]
  before_action :set_status, only: %i[show edit destroy review]
  before_action :set_presenter, only: %i[show edit review]

  def show
    authorize! @work

    # This updates the Work with the latest metadata from the Cocina object.
    # Does not update the Work's collection if the collection cannot be found.
    ModelSync::Work.call(work: @work, cocina_object: @cocina_object, raise: false)

    @review_form = ReviewForm.new
  end

  def new
    @collection = Collection.find_by!(druid: params.expect(:collection_druid))

    authorize! @collection, with: WorkPolicy

    @content = Content.create!(user: current_user)
    @work_form = new_work_form
    @license_presenter = LicensePresenter.new(work_form: @work_form, collection: @collection)

    render :form
  end

  def edit
    authorize! @work

    unless editable?
      flash[:danger] = helpers.t('works.edit.messages.cannot_be_edited')
      return redirect_to work_path(druid: params[:druid])
    end

    # This updates the Work with the latest metadata from the Cocina object.
    ModelSync::Work.call(work: @work, cocina_object: @cocina_object)
    @collection = @work.collection
    @license_presenter = LicensePresenter.new(work_form: @work_form, collection: @work.collection)

    render :form
  end

  def create # rubocop:disable Metrics/AbcSize
    @work_form = WorkForm.new(**work_params)
    @collection = Collection.find_by!(druid: @work_form.collection_druid)
    authorize! @collection, with: WorkPolicy

    # The validation_context param determines whether extra validations are applied, e.g., for deposits.
    if @work_form.valid?(validation_context)
      work = Work.create!(title: @work_form.title, user: current_user, collection: @collection)
      perform_deposit(work:)
      redirect_to wait_works_path(work.id)
    else
      @content = Content.find(@work_form.content_id)
      @license_presenter = LicensePresenter.new(work_form: @work_form, collection: @collection)
      render :form, status: :unprocessable_entity
    end
  end

  def update
    authorize! @work

    @work_form = WorkForm.new(**update_work_params)
    # The validation_context param determines whether extra validations are applied, e.g., for deposits.
    if @work_form.valid?(validation_context)
      perform_deposit(work: @work)
      redirect_to wait_works_path(@work.id)
    else
      @content = Content.find(@work_form.content_id)
      @collection = @work.collection
      @license_presenter = LicensePresenter.new(work_form: @work_form, collection: @work.collection)
      render :form, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! @work

    Sdr::Repository.discard_draft(druid: @work.druid)
    flash[:success] = helpers.t('messages.draft_discarded')
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
    authorize! work

    redirect_to work_path(druid: work.druid) unless work.deposit_persisting?
  end

  def review
    authorize! @work

    @review_form = ReviewForm.new(**review_form_params)
    if @review_form.valid?
      redirect_path = perform_review
      redirect_to redirect_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def work_params
    params.expect(work: WorkForm.user_editable_attributes + [WorkForm.nested_attributes])
  end

  def review_form_params
    params.expect(review: %i[review_option reject_reason])
  end

  def update_work_params
    work_params.merge(druid: params[:druid])
  end

  def set_work
    @work = Work.find_by!(druid: params[:druid])
  end

  def check_deposit_persisting
    redirect_to wait_works_path(@work.id) if @work.deposit_persisting?
  end

  def set_work_form_from_cocina
    @cocina_object = Sdr::Repository.find(druid: params[:druid])
    @work_form = ToWorkForm::Mapper.call(cocina_object: @cocina_object,
                                         doi_assigned: doi_assigned?, agree_to_terms: current_user.agree_to_terms?)
    @work_form.release_date = @collection.max_release_date if @work_form.release_option.blank?
  end

  def doi_assigned?
    DoiAssignedService.call(cocina_object: @cocina_object, work: @work)
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

  def set_presenter
    @work_presenter = WorkPresenter.new(work: @work, work_form: @work_form, version_status: @version_status)
  end

  def new_work_form
    WorkForm.new(
      collection_druid: @collection.druid,
      content_id: @content.id,
      license: @collection.license,
      access: @collection.stanford_access? ? 'stanford' : 'world',
      release_date: @collection.max_release_date,
      agree_to_terms: current_user.agree_to_terms?
    )
  end

  def perform_deposit(work:)
    work.deposit_persist! # Sets the deposit state
    DepositWorkJob.perform_later(work:, work_form: @work_form, deposit: deposit?, request_review: request_review?)
  end

  # @return [String] path to redirect to after review
  def perform_review
    if @review_form.review_option == 'approve'
      # Deposit
      @work.deposit_persist! # Sets the deposit state
      @work.approve!
      DepositWorkJob.perform_later(work: @work, work_form: @work_form, deposit: true, request_review: false)
      wait_works_path(@work.id)
    else
      @work.reject_with_reason!(reason: @review_form.reject_reason)
      work_path(druid: @work.druid)
    end
  end
end
