# frozen_string_literal: true

# Performs a deposit or a collection (without SDR API).
class DepositCollectionJob < ApplicationJob
  # @param [CollectionForm] collection_form
  # @param [Collection] collection
  # @param [Boolean] deposit if true, deposit the work; otherwise, leave as draft
  def perform(collection_form:, collection:, deposit:)
    @collection_form = collection_form
    @collection = collection

    new_cocina_object = perform_persist
    druid = new_cocina_object.externalIdentifier

    Sdr::Repository.accession(druid:) if deposit

    ModelSync::Collection.call(collection:, cocina_object: new_cocina_object)

    # The wait page will refresh until deposit_job_started_at is nil.
    collection.update!(deposit_job_started_at: nil, druid:)
  end

  private

  attr_reader :collection_form, :collection

  def perform_persist
    cocina_object = ToCocina::Collection::Mapper.call(collection_form:, source_id: "h3:collection-#{collection.id}")
    if collection_form.persisted?
      Sdr::Repository.open_if_needed(cocina_object:)
                     .then { |cocina_object| Sdr::Repository.update(cocina_object:) }
    else
      Sdr::Repository.register(cocina_object:)
    end
  end
end
