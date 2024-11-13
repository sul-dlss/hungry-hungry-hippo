# frozen_string_literal: true

# Performs a deposit (without SDR API).
class DepositJob < ApplicationJob
  # @param [WorkForm] work_form
  # @param [Work] work
  # @param [Boolean] deposit if true, deposit the work; otherwise, leave as draft
  def perform(work_form:, work:, deposit:)
    cocina_object = ToCocina::Mapper.call(work_form:, source_id: "h3:object-#{work.id}")
    # Until we're also doing updates:
    new_cocina_object = Sdr::Repository.register(cocina_object:)
    # new_cocina_object = if work_form.persisted?
    #                       Sdr::Repository.open_if_needed(cocina_object:)
    #                                      .then { |cocina_object| Sdr::Repository.update(cocina_object:) }
    #                     else
    #                       Sdr::Repository.register(cocina_object:)
    #                     end
    druid = new_cocina_object.externalIdentifier
    Sdr::Repository.accession(druid:) if deposit

    # Refresh the wait page. Since the deposit job is finished, this will redirect to the show page.
    work.update!(deposit_job_started_at: nil, druid:)
    # Just to be aware for future troubleshooting: There is a possible race condition between the websocket
    # connecting and the following broadcast being sent.
    Turbo::StreamsChannel.broadcast_refresh_to 'wait', work.id
  end
end
