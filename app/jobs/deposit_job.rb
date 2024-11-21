# frozen_string_literal: true

# Performs a deposit (without SDR API).
class DepositJob < ApplicationJob
  # @param [WorkForm, CollectionForm] form
  # @param [Work, Collection] object: the work or collectio
  # @param [String] source_id: the source_id of the object
  # @param [Boolean] deposit if true, deposit the work; otherwise, leave as draft
  def perform(form:, object:, source_id:, deposit:)
    content = Content.find(form.content_id)
    cocina_object = ToCocina::Mapper.call(form:, content:, source_id:)
    new_cocina_object = perform_persist(cocina_object:, update: form.persisted?)
    druid = new_cocina_object.externalIdentifier
    Sdr::Repository.accession(druid:) if deposit

    # Refresh the wait page. Since the deposit job is finished, this will redirect to the show page.
    object.update!(deposit_job_started_at: nil, druid:)
    # Just to be aware for future troubleshooting: There is a possible race condition between the websocket
    # connecting and the following broadcast being sent.
    sleep 0.5 if Rails.env.test? # Avoids race condition in tests
    Turbo::StreamsChannel.broadcast_refresh_to 'wait', object.id

    # Content isn't needed anymore
    content.destroy!
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
