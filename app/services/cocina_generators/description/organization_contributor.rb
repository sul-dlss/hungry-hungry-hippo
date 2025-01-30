# frozen_string_literal: true

module CocinaGenerators
  class Description
    # Generates the Cocina contributor parameters for an organization
    class OrganizationContributor
      def self.call(...)
        new(...).call
      end

      # @param name [String] the name of the organization
      # @param role [String] the role of the organization from ROLES
      # @param primary [Boolean] whether this is the first contributor
      def initialize(name:, role:, primary: false)
        @name = name
        @role = role
        @primary = primary
      end

      def call
        {
          name: [{ value: name }],
          type: contributor_type,
          role: role_params,
          status: ('primary' if primary)
        }.compact
      end

      private

      attr_reader :name, :role, :primary

      def role_params
        cocina_role = ContributorRole.call(role:)
        return if cocina_role.nil?

        [cocina_role]
      end

      def contributor_type
        return role if %w[event conference].include?(role)

        'organization'
      end
    end
  end
end
