# frozen_string_literal: true

module ToWorkForm
  # Maps Cocina DRO to WorkForm
  class Mapper
    def self.call(...)
      new(...).call
    end

    def initialize(cocina_object:, doi_assigned:, agree_to_terms:)
      @cocina_object = cocina_object
      @doi_assigned = doi_assigned
      @agree_to_terms = agree_to_terms
    end

    def call
      WorkForm.new(**params)
    end

    private

    attr_reader :cocina_object, :doi_assigned, :agree_to_terms

    def params # rubocop:disable Metrics/AbcSize
      {
        druid: cocina_object.externalIdentifier,
        lock: cocina_object.lock,
        title: Cocina::Parser.title_for(cocina_object:),
        contributors_attributes: ToWorkForm::ContributorsMapper.call(cocina_object:),
        abstract: ToForm::NoteMapper.abstract(cocina_object:),
        citation:,
        auto_generate_citation: citation.blank?,
        contact_emails_attributes: ToForm::ContactEmailsMapper.call(cocina_object:),
        related_works_attributes: ToWorkForm::RelatedWorksMapper.call(cocina_object:),
        related_links_attributes: ToForm::RelatedLinksMapper.call(cocina_object:),
        keywords_attributes: ToWorkForm::KeywordsMapper.call(cocina_object:),
        license:,
        access:,
        version: cocina_object.version,
        collection_druid: Cocina::Parser.collection_druid_for(cocina_object:),
        publication_date_attributes: ToWorkForm::PublicationDateMapper.call(cocina_object:),
        custom_rights_statement:,
        doi_option:,
        agree_to_terms:
      }.merge(ToWorkForm::WorkTypeMapper.call(cocina_object:))
        .merge(ToWorkForm::ReleaseDateMapper.call(cocina_object:))
        .merge(ToWorkForm::CreationDateMapper.call(cocina_object:))
    end

    def citation
      @citation ||= ToForm::NoteMapper.citation(cocina_object:)
    end

    def license
      cocina_object.access.license
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
  end
end
