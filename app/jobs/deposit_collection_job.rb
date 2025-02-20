# frozen_string_literal: true

# Performs a deposit or a collection (without SDR API).
class DepositCollectionJob < ApplicationJob
  # @param [CollectionForm] collection_form
  # @param [Collection] collection
  def perform(collection_form:, collection:)
    @collection_form = collection_form
    @collection = collection

    # If new_cocina_object then persist not performed since not changed.
    new_cocina_object = perform_persist
    druid = collection.druid || new_cocina_object.externalIdentifier

    update_collection_record(druid:)

    unless new_cocina_object
      collection.deposit_persist_complete!
      return
    end

    ModelSync::Collection.call(collection:, cocina_object: mapped_cocina_object)

    Sdr::Repository.accession(druid:)
    collection.accession!
  end

  private

  attr_reader :collection_form, :collection

  def mapped_cocina_object
    @mapped_cocina_object ||= ToCocina::Collection::Mapper.call(collection_form:,
                                                                source_id: "h3:collection-#{collection.id}")
  end

  def update_collection_record(druid:) # rubocop:disable Metrics/AbcSize
    collection.update!(druid:,
                       release_option: collection_form.release_option,
                       release_duration: collection_form.release_duration,
                       access: collection_form.access,
                       license_option: collection_form.license_option,
                       license:,
                       custom_rights_statement_option: collection_form.custom_rights_statement_option,
                       provided_custom_rights_statement: collection_form.provided_custom_rights_statement,
                       custom_rights_statement_instructions: collection_form.custom_rights_statement_instructions,
                       doi_option: collection_form.doi_option,
                       review_enabled: collection_form.review_enabled,
                       email_when_participants_changed: collection_form.email_when_participants_changed,
                       email_depositors_status_changed: collection_form.email_depositors_status_changed)

    assign_participants(:managers)
    assign_participants(:depositors)
    assign_participants(:reviewers)
  end

  def perform_persist
    if !collection_form.persisted?
      Sdr::Repository.register(cocina_object: mapped_cocina_object)
    elsif RoundtripSupport.changed?(cocina_object: mapped_cocina_object)
      Sdr::Repository.open_if_needed(cocina_object: mapped_cocina_object)
                     .then { |cocina_object| Sdr::Repository.update(cocina_object:) }
    end
  end

  # @param [Symbol] role :managers or :depositors
  #
  # Based on the provided role (:managers or :depositors), first clears the existing participants
  # in order to apply any deletes, then adds the participants from the form. If the added user
  # does not exist, it will be created and the name set to the sunetid until they login for the first time.
  # rubocop:disable Metrics/AbcSize
  def assign_participants(role)
    updated_users_for_role = []
    collection_form.send(:"#{role}_attributes").each do |participant|
      participant = participant.attributes if participant.respond_to?(:attributes)
      next if participant['sunetid'].blank?

      user = User.find_or_initialize_by(email_address: sunetid_to_email_address(participant['sunetid']))
      user.update!(name: participant['sunetid']) if user.name.blank?
      user.save!

      collection.send(role).append(user) unless collection.send(role).include?(user)
      updated_users_for_role.append(user)
    end

    remove_deleted_participants(role, updated_users_for_role)
  end
  # rubocop:enable Metrics/AbcSize

  # Remove any participants that are no longer in the form
  def remove_deleted_participants(role, participants)
    collection.send(role)
              .reject { |user| participants.include?(user) }
              .map { |user| collection.send(role).destroy(user) }
  end

  def sunetid_to_email_address(sunetid)
    "#{sunetid}#{User::EMAIL_SUFFIX}"
  end

  def license
    return collection_form.license if collection_form.license_option == 'required'

    collection_form.default_license
  end
end
