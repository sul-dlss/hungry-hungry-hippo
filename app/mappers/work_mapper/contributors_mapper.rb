# frozen_string_literal: true

class WorkMapper
  # Maps ContributorForms to Cocina contributor parameters
  class ContributorsMapper
    def self.call(...)
      new(...).call
    end

    # @param [Array<ContributorForm>] contributor_forms
    def initialize(contributor_forms:)
      @contributor_forms = contributor_forms
    end

    # @return [Array] the Cocina contributor parameters
    def call
      contributor_forms.filter_map.with_index do |contributor, index|
        # First is always status: "primary"
        primary = index.zero?
        if contributor.person?(with_names: true)
          person_for(contributor:, primary:)
        elsif contributor.organization?(with_names: true)
          organization_for(contributor:, primary:)
        end
      end
    end

    private

    attr_reader :contributor_forms

    def person_for(contributor:, primary:)
      Generators::Description.person_contributor(
        forename: contributor.first_name,
        surname: contributor.last_name,
        role: contributor.person_role,
        primary:,
        orcid: contributor.orcid,
        cited: contributor.cited
      )
    end

    def organization_for(contributor:, primary:)
      Generators::Description.organization_contributor(
        name: contributor.organization_name,
        role: contributor.organization_role,
        suborganization_name: contributor.suborganization_name,
        primary:,
        cited: contributor.cited
      )
    end
  end
end
