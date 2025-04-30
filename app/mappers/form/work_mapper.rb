# frozen_string_literal: true

# The containing namespace for mappers indicates what is being mapped *to*
module Form
  # Maps Cocina DRO (AKA "work") to WorkForm
  class WorkMapper
    def self.call(...)
      new(...).call
    end

    def initialize(cocina_object:, doi_assigned:, agree_to_terms:, version_description:, collection:)
      @cocina_object = cocina_object
      @doi_assigned = doi_assigned
      @agree_to_terms = agree_to_terms
      @version_description = version_description
      @collection = collection
    end

    def call
      WorkForm.new(**params)
    end

    private

    attr_reader :cocina_object, :doi_assigned, :agree_to_terms, :version_description, :collection

    def params # rubocop:disable Metrics/AbcSize
      {
        druid: cocina_object.externalIdentifier,
        lock: cocina_object.lock,
        title: Cocina::Parser.title_for(cocina_object:),
        contributors_attributes: WorkContributorsMapper.call(cocina_object:),
        abstract: NoteMapper.abstract(cocina_object:),
        citation:,
        contact_emails_attributes: ContactEmailsMapper.call(cocina_object:, works_contact_email:),
        related_works_attributes: RelatedWorksMapper.call(cocina_object:),
        related_links_attributes: RelatedLinksMapper.call(cocina_object:),
        keywords_attributes: WorkKeywordsMapper.call(cocina_object:),
        license:,
        access:,
        version: cocina_object.version,
        collection_druid: Cocina::Parser.collection_druid_for(cocina_object:),
        publication_date_attributes: WorkPublicationDateMapper.call(cocina_object:),
        custom_rights_statement:,
        doi_option:,
        agree_to_terms:,
        works_contact_email:,
        whats_changing: version_description,
        deposit_creation_date:,
        apo: Cocina::Parser.apo_for(cocina_object:)
      }.merge(WorkTypeMapper.call(cocina_object:))
        .merge(WorkReleaseDateMapper.call(cocina_object:))
        .merge(WorkCreationDateMapper.call(cocina_object:))
    end

    def works_contact_email
      return unless collection&.works_contact_email

      return unless cocina_object.description.access.accessContact.any? do |access_contact|
        access_contact.value == collection.works_contact_email
      end

      collection.works_contact_email
    end

    def citation
      @citation ||= NoteMapper.citation(cocina_object:)
    end

    def license
      cocina_object.access.license || License::NO_LICENSE_ID
    end

    def custom_rights_statement
      use_statement = cocina_object.access.useAndReproductionStatement
      return if use_statement.blank?
      return if use_statement == default_terms_of_use

      # Remove the default terms
      use_statement.delete_suffix(default_terms_of_use)&.strip
    end

    def default_terms_of_use
      I18n.t('license.terms_of_use')
    end

    def doi_option
      # If the work has a DOI and that DOI exists in DataCite, then already assigned.
      # If the work has a DOI and that DOI does not exist in DataCite, then yes.
      # (It will be assigned as part of the registration request or when deposited.)
      # If the work does not have a DOI, then no.
      doi = Cocina::Parser.doi_for(cocina_object:)
      if doi.nil?
        'no'
      elsif doi_assigned
        'assigned'
      else
        'yes'
      end
    end

    def access
      # When there is an embargo, the embargo view is the access view.
      cocina_object.access&.embargo&.view || cocina_object.access.view
    end

    def deposit_creation_date
      creation_event = Array(cocina_object.description&.adminMetadata&.event).find { |event| event.type == 'creation' }
      return unless creation_event

      creation_event.date.first&.value
    end
  end
end
