# frozen_string_literal: true

# Performs a deposit or a collection (without SDR API).
class DepositCollectionJob < ApplicationJob
  # @param [CollectionForm] collection_form
  # @param [Collection] collection
  def perform(collection_form:, collection:)
    @collection_form = collection_form
    @collection = collection

    new_cocina_object = perform_persist
    druid = new_cocina_object.externalIdentifier

    collection.update!(druid:,
                       release_option: @collection_form.release_option,
                       release_duration: @collection_form.release_duration,
                       access: @collection_form.access,
                       license_option: @collection_form.license_option,
                       license:,
                       doi_option: @collection_form.doi_option)

    assign_participants(:managers)
    assign_participants(:depositors)

    ModelSync::Collection.call(collection:, cocina_object: new_cocina_object)

    Sdr::Repository.accession(druid:)
    collection.accession!
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

  # @param [Symbol] role :managers or :depositors
  #
  # Based on the provided role (:managers or :depositors), first clears the existing participants
  # in order to apply any deletes, then adds the participants from the form. If the added user
  # does not exist, it will be created and the name set to the sunetid until they login for the first time.
  # rubocop:disable Metrics/AbcSize
  def assign_participants(role)
    collection.send(role).clear
    collection_form.send(:"#{role}_attributes").each do |participant|
      participant = participant.attributes if participant.respond_to?(:attributes)
      next if participant['sunetid'].blank?

      user = User.find_or_initialize_by(email_address: sunetid_to_email_address(participant['sunetid']))
      user.update!(name: participant['sunetid']) if user.name.blank?
      user.save!

      collection.send(role).append(user)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def sunetid_to_email_address(sunetid)
    "#{sunetid}#{User::EMAIL_SUFFIX}"
  end

  def license
    return @collection_form.license if @collection_form.license_option == 'required'

    @collection_form.suggested_license
  end
end
