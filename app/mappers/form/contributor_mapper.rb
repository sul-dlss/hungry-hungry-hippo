# frozen_string_literal: true

module Form
  # Maps a Contributor AR model to a ContributorForm attributes
  class ContributorMapper
    def self.call(...)
      new(...).call
    end

    def initialize(contributor:)
      @contributor = contributor
    end

    def call
      if contributor.person?
        person_attributes
      else
        organization_attributes
      end
    end

    private

    attr_reader :contributor

    def person_attributes
      contributor.attributes.slice('first_name', 'last_name', 'role_type', 'orcid').symbolize_keys.tap do |attributes|
        attributes[:person_role] = contributor.role
        attributes[:with_orcid] = contributor.orcid.present?
        attributes[:stanford_degree_granting_institution] = false
        attributes[:affiliations_attributes] = affiliation_attributes
      end
    end

    def organization_attributes
      contributor.attributes.slice('organization_name', 'role_type',
                                   'suborganization_name').symbolize_keys.tap do |attributes|
        attributes[:organization_role] = contributor.role
        attributes[:stanford_degree_granting_institution] =
          contributor.role == 'degree_granting_institution' && contributor.organization_name == 'Stanford University'
        attributes[:with_orcid] = false
        attributes[:affiliations_attributes] = [] # Required to avoid empty Affiliations form(s)
      end
    end

    def affiliation_attributes
      return [] unless contributor.affiliations.any?

      contributor.affiliations.map do |affiliation|
        affiliation.attributes.slice('institution', 'uri', 'department').symbolize_keys
      end
    end
  end
end
