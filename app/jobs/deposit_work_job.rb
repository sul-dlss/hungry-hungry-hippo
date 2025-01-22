# frozen_string_literal: true

# Performs a deposit or a work (without SDR API).
class DepositWorkJob < ApplicationJob
  # @param [WorkForm] work_form
  # @param [Work] work
  # @param [Boolean] deposit if true and review is not requested, deposit the work; otherwise, leave as draft
  # @param [Boolean] request_review if true, request view of the work
  def perform(work_form:, work:, deposit:, request_review:) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    @work_form = work_form
    @work = work
    @deposit = deposit
    @request_review = request_review

    # Add missing digests and mime types
    Contents::Analyzer.call(content:)
    new_cocina_object = perform_persist
    druid = new_cocina_object.externalIdentifier

    work.update!(druid:)

    Contents::Stager.call(content:, druid:)

    ModelSync::Work.call(work:, cocina_object: new_cocina_object)

    update_terms_of_deposit!

    if deposit?
      Sdr::Repository.accession(druid:)
      work.accession!
    else
      work.deposit_persist_complete!
    end
    work.request_review! if request_review?

    # Content isn't needed anymore
    content.destroy!
  end

  private

  attr_reader :work_form, :work

  def content
    @content ||= Content.find(work_form.content_id)
  end

  def perform_persist
    cocina_object = ToCocina::Work::Mapper.call(work_form:, content:, source_id: "h3:object-#{work.id}")

    if work_form.persisted?
      Sdr::Repository.open_if_needed(cocina_object:)
                     .then { |cocina_object| Sdr::Repository.update(cocina_object:) }
    else
      Sdr::Repository.register(cocina_object:, assign_doi:)
    end
  end

  def assign_doi
    work_form.doi_option == 'yes'
  end

  def update_terms_of_deposit!
    return if user.agree_to_terms?

    user.update!(agreed_to_terms_at: Time.zone.now)
  end

  def user
    work.user
  end

  # If request review, deposit will be saved, but not deposited until approved.
  def deposit?
    request_review? ? false : @deposit
  end

  def request_review?
    @request_review
  end
end
