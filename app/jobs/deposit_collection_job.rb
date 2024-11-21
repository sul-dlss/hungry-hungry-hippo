# frozen_string_literal: true

# Performs a deposit (without SDR API).
class DepositCollectionJob < ApplicationJob
  # @param [CollectionForm] collection_form
  # @param [Collection] collection
  # @param [Boolean] deposit if true, deposit the collection; otherwise, leave as draft
  def perform(collection_form:, collection:, deposit:)
    cocina_object = ToCocina::CollectionMapper.call(collection_form:, source_id: "h3:collection-#{collection.id}")
    new_cocina_object = if collection_form.persisted?
                          Sdr::Repository.open_if_needed(cocina_object:)
                                         .then { |cocina_object| Sdr::Repository.update(cocina_object:) }
                        else
                          Sdr::Repository.register(cocina_object:)
                        end
    druid = new_cocina_object.externalIdentifier
    Sdr::Repository.accession(druid:) if deposit

    # Refresh the wait page. Since the deposit job is finished, this will redirect to the show page.
    collection.update!(deposit_job_started_at: nil, druid:)
    # Just to be aware for future troubleshooting: There is a possible race condition between the websocket
    # connecting and the following broadcast being sent.
    sleep 0.5 if Rails.env.test? # Avoids race condition in tests
    Turbo::StreamsChannel.broadcast_refresh_to 'wait', collection.id
  end
end
