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

    assign_participants(:managers)
    assign_participants(:depositors)

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

  def assign_participants(role)
    collection.send(role).clear
    collection_form.send(:"#{role}_attributes").each do |participant|
      participant = participant.attributes if participant.respond_to?(:attributes)
      next if participant['sunetid'].blank?

      user = User.find_or_create_by(email_address: sunetid_to_email_address(participant['sunetid']))
      collection.send(role).append(user)
    end
  end

  def sunetid_to_email_address(sunetid)
    "#{sunetid}#{User::EMAIL_SUFFIX}"
  end
end
