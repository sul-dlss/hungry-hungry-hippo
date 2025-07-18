# frozen_string_literal: true

# Performs a deposit or a collection (without SDR API).
class DepositCollectionJob < ApplicationJob
  # @param [CollectionForm] collection_form
  # @param [Collection] collection
  # @param [User] current_user
  def perform(collection_form:, collection:, current_user:)
    @collection_form = collection_form
    @collection = collection
    # Setting current user so that it will be available for notifications.
    Current.user = current_user

    # If new_cocina_object then persist not performed since not changed.
    new_cocina_object = perform_persist
    @druid = collection.druid || new_cocina_object.externalIdentifier

    submit_sdr_event # This has to be called before persisting to SDR.
    update_collection_record

    if new_cocina_object
      CollectionModelSynchronizer.call(collection:, cocina_object: new_cocina_object)
      collection.accession!
      Sdr::Repository.accession(druid:)
    else
      collection.deposit_persist_complete!
    end
  end

  private

  attr_reader :collection_form, :collection, :druid

  def user_name
    Current.user.sunetid
  end

  def mapped_cocina_object
    @mapped_cocina_object ||= Cocina::CollectionMapper.call(collection_form:,
                                                            source_id: "h3:collection-#{collection.id}")
  end

  def update_collection_record # rubocop:disable Metrics/AbcSize
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
                       email_depositors_status_changed: collection_form.email_depositors_status_changed,
                       work_type: collection_form.work_type,
                       work_subtypes: collection_form.work_subtypes,
                       works_contact_email: collection_form.works_contact_email)
    assign_participants(:managers)
    assign_participants(:depositors)
    assign_participants(:reviewers)
    assign_contributors
  end

  def perform_persist
    if !collection_form.persisted?
      Sdr::Repository.register(cocina_object: mapped_cocina_object, user_name:)
    elsif RoundtripSupport.changed?(cocina_object: mapped_cocina_object)
      Sdr::Repository.open_if_needed(cocina_object: mapped_cocina_object, user_name:)
                     .then { |cocina_object| Sdr::Repository.update(cocina_object:, user_name:) }
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

      user = User.create_with(name: participant['name'])
                 .find_or_create_by!(email_address: sunetid_to_email_address(participant['sunetid']))

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

  def assign_contributors
    collection.contributors.clear
    collection_form.contributors.each do |contributor_form|
      if contributor_form.person?(with_names: true)
        assign_person(contributor_form:)
      elsif contributor_form.organization?(with_names: true)
        assign_organization(contributor_form:)
      end
    end
  end

  def assign_person(contributor_form:)
    contributor = collection.contributors.create!(first_name: contributor_form.first_name,
                                                  last_name: contributor_form.last_name,
                                                  role: contributor_form.person_role,
                                                  role_type: 'person',
                                                  orcid: contributor_form.with_orcid ? contributor_form.orcid : nil)
    contributor_form.affiliations.each do |affiliation_form|
      contributor.affiliations.create!(institution: affiliation_form.institution,
                                       uri: affiliation_form.uri,
                                       department: affiliation_form.department)
    end
  end

  def assign_organization(contributor_form:)
    collection.contributors.create!(organization_name: contributor_form.organization_name,
                                    role: contributor_form.organization_role,
                                    role_type: 'organization',
                                    suborganization_name: suborganization_name_for(contributor_form:))
  end

  def suborganization_name_for(contributor_form:)
    contributor_form.stanford_degree_granting_institution ? contributor_form.suborganization_name : nil
  end

  def submit_sdr_event
    return unless collection_form.persisted?

    setting_changes = SettingChangesDiffer.call(collection_form:, collection:)

    return if setting_changes.blank?

    Sdr::Event.create(druid:,
                      type: 'h3_collection_settings_updated',
                      data: {
                        who: user_name,
                        description: setting_changes.join(', ')
                      })
  end

  # Determines the setting changes between the current collection and the new collection form.
  # This must be called before the collection has been updated.
  class SettingChangesDiffer
    def self.call(...)
      new(...).call
    end

    def initialize(collection_form:, collection:)
      @collection_form = collection_form
      @collection = collection
    end

    # @return [Array<String>] a list of changes made to the collection
    def call # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength
      [].tap do |changes|
        changes << 'When files are downloadable modified' if changed?(:release_option, :release_duration)
        changes << 'Who can download files modified' if changed?(:access)
        changes << 'DOI setting modified' if changed?(:doi_option)
        changes << 'License setting modified' if changed?(:license_option, :license)
        changes << 'Notification settings modified' if changed?(:email_when_participants_changed,
                                                                :email_depositors_status_changed)
        changes << 'Review workflow settings modified' if changed?(:review_enabled)
        changes << 'Custom terms of use modified' if changed?(:custom_rights_statement_option,
                                                              :provided_custom_rights_statement,
                                                              :custom_rights_statement_instructions)
        changes << "Added depositors: #{added_depositors.join('; ')}" if added_depositors.present?
        changes << "Removed depositors: #{removed_depositors.join('; ')}" if removed_depositors.present?
        changes << "Added managers: #{added_managers.join('; ')}" if added_managers.present?
        changes << "Removed managers: #{removed_managers.join('; ')}" if removed_managers.present?
        changes << 'Type of deposit modified' if changed?(:work_type, :work_subtypes)
        changes << 'Work email modified' if changed?(:works_contact_email)
        changes << 'Work contributors modified' if nested_changed?(:contributors)
      end
    end

    private

    attr_reader :collection_form, :collection

    def original_collection_form
      @original_collection_form ||= Form::CollectionMapper.call(cocina_object:, collection:)
    end

    def cocina_object
      Sdr::Repository.find(druid: collection.druid)
    end

    def changed?(*fields)
      fields.any? { |field| collection_form.send(field).presence != original_collection_form.send(field).presence }
    end

    def added_depositors
      @added_depositors ||= (collection_form_depositors - collection_depositors).to_a
    end

    def removed_depositors
      @removed_depositors ||= (collection_depositors - collection_form_depositors).to_a
    end

    def collection_depositors
      @collection_depositors ||= collection.depositors.pluck(:name).to_set
    end

    def collection_form_depositors
      @collection_form_depositors ||= collection_form.depositors.filter_map(&:name).to_set
    end

    def added_managers
      @added_managers ||= (collection_form_managers - collection_managers).to_a
    end

    def removed_managers
      @removed_managers ||= (collection_managers - collection_form_managers).to_a
    end

    def collection_managers
      @collection_managers ||= collection.managers.pluck(:name).to_set
    end

    def collection_form_managers
      @collection_form_managers ||= collection_form.managers.filter_map(&:name).to_set
    end

    def nested_changed?(*fields)
      fields.any? do |field|
        nested_field(collection_form, field) != nested_field(original_collection_form, field)
      end
    end

    def nested_field(form, field)
      nested_forms = form.send(field).reject(&:empty?)
      nested_forms.to_set(&:attributes)
    end
  end
end
