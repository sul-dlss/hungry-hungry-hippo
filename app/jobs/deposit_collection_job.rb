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
    set_managers
    set_depositors

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

  def set_managers
    collection.managers.clear
    collection_form.managers_attributes.each do |manager|
      # Sometimes this is a hash and sometimes it is a ManagerForm object.
      manager = manager.attributes if manager.respond_to?(:attributes)
      user = User.find_or_create_by(email_address: "#{manager['sunetid']}@stanford.edu")
      collection.managers.append(user)
    end
  end

  def set_depositors
    collection.depositors.clear
    collection_form.depositors_attributes.each do |depositor|
      # Sometimes this is a hash and sometimes it is a DepositorForm object.
      depositor = depositor.attributes if depositor.respond_to?(:attributes)
      user = User.find_or_create_by(email_address: "#{depositor['sunetid']}@stanford.edu")
      collection.depositors.append(user)
    end
  end
end
