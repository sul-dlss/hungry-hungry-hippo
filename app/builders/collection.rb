# frozen_string_literal: true

module Builders
  # Builds CollectionForm from a Cocina collection
  class Collection
    def self.call(...)
      new(...).call
    end

    def initialize(cocina_object:, collection:)
      @cocina_object = cocina_object
      @collection = collection
    end

    def call
      CollectionForm.new(params)
    end

    private

    attr_reader :cocina_object, :collection

    # rubocop:disable Metrics/AbcSize
    def params
      {
        druid: cocina_object.externalIdentifier,
        lock: cocina_object.lock,
        title: Cocina::Parser.title_for(cocina_object:),
        description: ToForm::NoteMapper.abstract(cocina_object:), # Cocina abstract maps to Collection description
        contact_emails_attributes: ToForm::ContactEmailsMapper.call(cocina_object:),
        related_links_attributes: ToForm::RelatedLinksMapper.call(cocina_object:),
        release_option: collection.release_option,
        release_duration: collection.release_duration,
        access: collection.access,
        license_option: collection.license_option,
        doi_option: collection.doi_option,
        managers_attributes: participant_attributes(:managers),
        depositors_attributes: participant_attributes(:depositors),
        version: cocina_object.version,
        review_enabled: collection.review_enabled,
        reviewers_attributes: participant_attributes(:reviewers),
        email_when_participants_changed: collection.email_when_participants_changed,
        email_depositors_status_changed: collection.email_depositors_status_changed,
        custom_rights_statement_option: collection.custom_rights_statement_option,
        provided_custom_rights_statement: collection.provided_custom_rights_statement,
        custom_rights_statement_instructions: collection.custom_rights_statement_instructions,
        work_type: collection.work_type,
        work_subtypes: collection.work_subtypes,
        works_contact_email: collection.works_contact_email,
        contributors_attributes:
      }.merge(license_params)
    end
    # rubocop:enable Metrics/AbcSize

    # @param [Symbol] role :managers, :reviewers, or :depositors
    # @return [Array<Hash>] an array of participant attributes
    # Creates the attribute hash of sunetids for the given role to be used in the CollectionForm
    def participant_attributes(role)
      collection.send(role).map do |participant|
        {
          sunetid: participant.sunetid,
          name: participant.name
        }
      end
    end

    def license_params
      return { license: collection.license } if collection.license_option == 'required'

      { default_license: collection.license }
    end

    def contributors_attributes
      return [{}] if collection.contributors.blank?

      collection.contributors.map { |contributor| ToForm::ContributorMapper.call(contributor:) }
    end
  end
end
