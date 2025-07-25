# frozen_string_literal: true

# The containing namespace for mappers indicates what is being mapped *to*
module Form
  # Maps contributors to the work form
  class WorkContributorsMapper < BaseMapper
    ORGANIZATION_TYPES = %w[organization conference event].freeze

    def call
      return nil if cocina_object.description.contributor.blank?

      cocina_object.description.contributor.filter_map do |contributor|
        WorkContributorMapper.new(contributor:).call
      end.presence
    end

    # Maps an individual contributor
    class WorkContributorMapper
      def initialize(contributor:)
        @contributor = contributor
      end

      def call
        {
          'first_name' => first_name,
          'last_name' => last_name,
          'role_type' => organization? ? 'organization' : 'person',
          'person_role' => (role if person?),
          'organization_role' => (role if organization?),
          'organization_name' => organization_name,
          'suborganization_name' => suborganization_name,
          'stanford_degree_granting_institution' => stanford_degree_granting_institution?,
          'orcid' => orcid,
          'with_orcid' => orcid.present?,
          'affiliations_attributes' => affiliations
        }
      end

      private

      attr_reader :contributor

      def affiliations
        Array(contributor.affiliation).map do |affiliation|
          affiliation_from(affiliation)
        end
      end

      def affiliation_from(affiliation)
        institution = affiliation.structuredValue.find { |descriptive_value| descriptive_value.identifier.present? }
        department = affiliation.structuredValue.find { |descriptive_value| descriptive_value.identifier.blank? }

        {
          'institution' => institution.value,
          'uri' => institution.identifier.find { |id| id.type == 'ROR' }&.uri,
          'department' => department&.value
        }.compact
      end

      def first_name
        full_name.find { |name| name.type == 'forename' }&.value
      end

      def last_name
        full_name.find { |name| name.type == 'surname' }&.value
      end

      def organization_name
        return nil unless organization?

        contributor.name.first&.value || contributor.name.first.structuredValue.first.value
      end

      def orcid
        @orcid ||= contributor.identifier&.find { |id| id.type == 'ORCID' }&.value&.presence
      end

      def full_name
        @full_name ||= contributor.name.first&.structuredValue
      end

      def person?
        contributor.type == 'person'
      end

      def organization?
        ORGANIZATION_TYPES.include?(contributor.type)
      end

      def role
        @role ||= ContributorRoleCocinaBuilder::ROLES.keys.find do |key|
          ContributorRoleCocinaBuilder::ROLES.dig(key, :value) == contributor.role.first&.value
        end&.to_s
      end

      def stanford_degree_granting_institution?
        @stanford_degree_granting_institution ||= organization_name == WorkForm::STANFORD_UNIVERSITY &&
                                                  role == 'degree_granting_institution'
      end

      def suborganization_name
        return unless stanford_degree_granting_institution?

        contributor.name.first.structuredValue&.second&.value
      end
    end
  end
end
