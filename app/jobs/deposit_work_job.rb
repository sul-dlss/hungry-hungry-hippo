# frozen_string_literal: true

# Performs a deposit or a work (without SDR API).
class DepositWorkJob < ApplicationJob
  # @param [WorkForm] work_form
  # @param [Work] work
  # @param [Boolean] deposit if true, deposit the work; otherwise, leave as draft
  def perform(work_form:, work:, deposit:)
    @work_form = work_form
    @work = work

    # Add missing digests and mime types
    Contents::Analyzer.call(content:)
    new_cocina_object = perform_persist
    druid = new_cocina_object.externalIdentifier

    Contents::Stager.call(content:, druid:)

    Sdr::Repository.accession(druid:) if deposit

    ModelSync::Work.call(work:, cocina_object: new_cocina_object)

    # The wait page will refresh until deposit_job_started_at is nil.
    work.update!(deposit_job_started_at: nil, druid:)

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
      Sdr::Repository.register(cocina_object:)
    end
  end
end
