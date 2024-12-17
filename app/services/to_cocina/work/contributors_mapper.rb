# frozen_string_literal: true

module ToCocina
  module Work
    # Maps ContributorForms to a Cocina contributor parameters
    class ContributorsMapper
      def self.call(...)
        new(...).call
      end

      # @param [Array<ContributorForm>] contributor_forms
      def initialize(contributor_forms:)
        @contributor_forms = contributor_forms
      end

      # @return [Hash] the Cocina contributor parameters
      def call
        contributor_forms.filter_map.with_index do |contributor, index|
          # First entered contributor is always status: "primary" (except for Publisher)
          primary = index.zero?
          if person?(contributor)
            CocinaGenerators::Description.person_contributor(
              forename: contributor.first_name,
              surname: contributor.last_name,
              role: contributor.person_role,
              primary:,
              orcid: contributor.orcid
            )
          elsif organization?(contributor)
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

      def person?(contributor)
        contributor.role_type == 'person' && contributor.first_name.present? && contributor.last_name.present?
      end

      def organization?(contributor)
        contributor.role_type == 'organization' && contributor.organization_name.present?
      end
    end
  end
end
