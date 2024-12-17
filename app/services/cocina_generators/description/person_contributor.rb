# frozen_string_literal: true

module CocinaGenerators
  class Description
    # Generates the Cocina contributor parameters for a person
    class PersonContributor
      def self.call(...)
        new(...).call
      end

      # @param surname [String] the surname of the person
      # @param forename [String] the forename of the person
      # @param role [String] the role of the person from ROLES
      # @param primary [Boolean] whether this is the first author
      # @param orcid [String] the ORCID of the person
      def initialize(surname:, forename:, role:, primary: false, orcid: nil)
        @surname = surname
        @forename = forename
        @role = role
        @primary = primary
        @orcid = orcid
      end

      def call
        {
          name: [
            {
              structuredValue: [
                { value: forename, type: 'forename' },
                { value: surname, type: 'surname' }
              ]
            }
          ],
          type: 'person',
          role: role_params,
          identifier: identifier_params,
          status: ('primary' if primary)

          # NOTE: affiliations.map { |affiliation_attrs| affiliation(**affiliation_attrs) }.presence
        }.compact
      end

      private

      attr_reader :forename, :surname, :role, :primary, :orcid

      def role_params
        cocina_role = ContributorRole.call(role:)
        return if cocina_role.nil?

        [cocina_role]
      end

      def identifier_params
        return if orcid.nil?

        [
          {
            value: orcid,
            type: 'ORCID',
            source: { uri: Settings.orcid.url }
          }
        ]
      end
    end
  end
end
