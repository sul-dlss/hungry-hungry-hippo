# frozen_string_literal: true

# Performs a deposit (without SDR API).
class DepositJob < ApplicationJob
  # @param [WorkForm] work_form
  # @param [Work] work
  # @param [Boolean] deposit if true, deposit the work; otherwise, leave as draft
  def perform(work_form:, work:, deposit:)
    content = Content.find(work_form.content_id)
    cocina_object = ToCocina::Mapper.call(work_form:, content:, source_id: "h3:object-#{work.id}")
    new_cocina_object = perform_persist(cocina_object:, update: work_form.persisted?)
    druid = new_cocina_object.externalIdentifier
    Sdr::Repository.accession(druid:) if deposit

    ModelSync::Work.call(work:, cocina_object: new_cocina_object)
    work.update!(deposit_job_started_at: nil, druid:)
    # Refresh the wait page. Since the deposit job is finished, this will redirect to the show page.
    # Just to be aware for future troubleshooting: There is a possible race condition between the websocket
    # connecting and the following broadcast being sent.
    sleep 0.5 if Rails.env.test? # Avoids race condition in tests
    Turbo::StreamsChannel.broadcast_refresh_to 'wait', work.id
  end

  def perform_persist(cocina_object:, update:)
    if update
      Sdr::Repository.open_if_needed(cocina_object:)
                     .then { |cocina_object| Sdr::Repository.update(cocina_object:) }
    else
      Sdr::Repository.register(cocina_object:)
    end
  end
end
