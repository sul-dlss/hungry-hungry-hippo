# frozen_string_literal: true

module ToCocina
  module Work
    # Maps AuthorForms to Cocina contributor parameters
    class ContributorsMapper
      def self.call(...)
        new(...).call
      end

      # @param [Array<AuthorForm>] author_forms
      def initialize(author_forms:)
        @author_forms = author_forms
      end

      # @return [Array] the Cocina contributor parameters
      def call
        author_forms.filter_map.with_index do |author, index|
          # First is always status: "primary"
          primary = index.zero?
          if author.person?(with_names: true)
            CocinaGenerators::Description.person_contributor(
              forename: author.first_name,
              surname: author.last_name,
              role: author.person_role,
              primary:,
              orcid: author.orcid
            )
          elsif author.organization?(with_names: true)
            CocinaGenerators::Description.organization_contributor(
              name: author.organization_name,
              role: author.organization_role,
              primary:
            )
          end
        end
      end

      private

      attr_reader :author_forms
    end
  end
end
