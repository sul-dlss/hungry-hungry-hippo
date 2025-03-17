# frozen_string_literal: true

# Controller for a Work
class WorksController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :set_work_and_collection, only: %i[show edit update destroy review]
  before_action :check_deposit_registering_or_updating, only: %i[show edit]
  before_action :set_status, only: %i[show edit destroy review update]
  before_action :set_work_form_from_cocina, only: %i[show edit review]
  before_action :set_content, only: %i[show edit review]
  before_action :set_presenter, only: %i[show edit review]
  before_action :set_license_presenter, only: %i[edit]

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
    set_license_presenter # Note this requires @collection and @work_form set above.
    mark_collection_required_contributors # Note this requires @collection and @work_form set above.

    render :form
  end

  def edit
    authorize! @work

    unless editable?
      flash[:warning] = helpers.t('works.edit.messages.cannot_be_edited_html', support_email: Settings.support_email)
      return redirect_to work_path(params[:druid]), status: :see_other
    end

    # This updates the Work with the latest metadata from the Cocina object.
    ModelSync::Work.call(work: @work, cocina_object: @cocina_object)

    mark_collection_required_contributors

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
      set_license_presenter
      render :form, status: :unprocessable_entity
    end
  end

  def update # rubocop:disable Metrics/AbcSize
    authorize! @work

    @work_form = WorkForm.new(**update_work_params)
    @content = Content.find(@work_form.content_id)

    work_is_valid = @work_form.valid?(validation_context)

    if work_is_valid && perform_deposit?
      perform_deposit(work: @work)
      redirect_to wait_works_path(@work.id)
    else
      flash.now[:warning] = helpers.t('works.edit.messages.no_changes') if work_is_valid
      set_license_presenter
      set_presenter
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
      redirect_to collection_path(collection_druid)
    else
      redirect_to work_path(@work)
    end
  end

  def wait
    @work = Work.find(params[:id])
    authorize! @work

    # Don't show flashes on wait and preserve them for the next page
    @no_flash = true
    flash.keep

    redirect_to work_path(@work) unless @work.deposit_registering_or_updating?
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

  def set_work_and_collection
    @work = Work.find_by!(druid: params[:druid])
    @collection = @work.collection
  end

  def check_deposit_registering_or_updating
    redirect_to wait_works_path(@work.id) if @work.deposit_registering_or_updating?
  end

  def set_work_form_from_cocina
    @cocina_object = Sdr::Repository.find(druid: params[:druid])
    version_description = @version_status.open? ? @version_status.version_description : nil
    @work_form = ToWorkForm::Mapper.call(cocina_object: @cocina_object, doi_assigned: doi_assigned?,
                                         agree_to_terms: current_user.agree_to_terms?,
                                         version_description:, collection: @collection)
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

    ToWorkForm::RoundtripValidator.call(work_form: @work_form, cocina_object: @cocina_object,
                                        content: @content)
  end

  def set_presenter
    @work_presenter = WorkPresenter.new(work: @work, work_form: @work_form, version_status: @version_status)
  end

  def set_license_presenter
    @license_presenter = LicensePresenter.new(work_form: @work_form, collection: @collection)
  end

  def new_work_form # rubocop:disable Metrics/AbcSize
    WorkForm.new(
      collection_druid: @collection.druid,
      content_id: @content.id,
      license: @collection.license,
      access: @collection.stanford_access? ? 'stanford' : 'world',
      agree_to_terms: current_user.agree_to_terms?,
      contact_emails_attributes: [{ email: current_user.email_address }],
      work_type: @collection.work_type,
      work_subtypes: @collection.work_subtypes,
      works_contact_email: @collection.works_contact_email
    ).tap do |work_form|
      if @collection.contributors.present?
        work_form.contributors_attributes = @collection.contributors.map do |contributor|
          ToForm::ContributorMapper.call(contributor:)
        end
      end
    end
  end

  def perform_deposit(work:)
    work.deposit_persist! # Sets the deposit state
    DepositWorkJob.perform_later(work:, work_form: @work_form, deposit: deposit?, request_review: request_review?,
                                 current_user:)
  end

  # @return [String] path to redirect to after review
  def perform_review
    if @review_form.review_option == 'approve'
      # Deposit
      @work.deposit_persist! # Sets the deposit state
      @work.approve!
      DepositWorkJob.perform_later(work: @work, work_form: @work_form, deposit: true, request_review: false,
                                   current_user:)
      wait_works_path(@work.id)
    else
      @work.reject_with_reason!(reason: @review_form.reject_reason)
      work_path(@work)
    end
  end

  def deposit?
    params[:commit] == 'Deposit'
  end

  # NOTE: a `nil` validation context runs all validations without an explicit context
  def validation_context
    return :deposit if deposit? || request_review?

    nil
  end

  def perform_deposit?
    # Open? indicates that a previous change was made.
    # A previous change is OK for deposit or requesting review, but not saving draft.
    return true if @version_status.open? && (deposit? || request_review?)

    # If no previous change, then check for a current change.
    mapped_cocina_object = ToCocina::Work::Mapper.call(work_form: @work_form, content: @content,
                                                       source_id: "h3:object-#{@work.id}")
    RoundtripSupport.changed?(cocina_object: mapped_cocina_object)
  end

  def mark_collection_required_contributors
    collection_contributors = @collection.contributors.map do |contributor|
      ContributorForm.new(ToForm::ContributorMapper.call(contributor:)).attributes
    end

    @work_form.contributors.each do |contributor|
      contributor.collection_required = collection_contributors.include?(contributor.attributes)
    end
  end
end
