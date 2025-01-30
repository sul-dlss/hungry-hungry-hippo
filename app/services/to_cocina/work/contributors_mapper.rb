# frozen_string_literal: true

module ToCocina
  module Work
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
            CocinaGenerators::Description.person_contributor(
              forename: contributor.first_name,
              surname: contributor.last_name,
              role: contributor.person_role,
              primary:,
              orcid: contributor.orcid
            )
          elsif contributor.organization?(with_names: true)
            CocinaGenerators::Description.organization_contributor(
              name: contributor.organization_name,
              role: contributor.organization_role,
              primary:
            )
          end
        end
      end

      private

      attr_reader :contributor_forms
    end
  end
end
