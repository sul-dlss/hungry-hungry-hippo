# frozen_string_literal: true

module ToWorkForm
  # Maps contributors.
  class ContributorsMapper < ToForm::BaseMapper
    def call
      return nil if cocina_object.description.contributor.blank?

      cocina_object.description.contributor.filter_map do |contributor|
        ContributorMapper.new(contributor:).call
      end.presence
    end

    # Maps an individual contributor.
    class ContributorMapper
      def initialize(contributor:)
        @contributor = contributor
      end

      def call
        { 'first_name' => first_name,
          'last_name' => last_name,
          'role_type' => contributor.type,
          'person_role' => (role if person?),
          'organization_role' => (role if organization?),
          'organization_name' => organization_name,
          'suborganization_name' => suborganization_name,
          'stanford_degree_granting_institution' => stanford_degree_granting_institution?,
          'orcid' => orcid,
          'with_orcid' => orcid.present?,
          'cited' => cited? }
      end

      private

      attr_reader :contributor

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
        contributor.type == 'organization'
      end

      def role
        contributor.role.first&.value&.tr(' ', '_')
      end

      def stanford_degree_granting_institution?
        @stanford_degree_granting_institution ||= organization_name == WorkForm::STANFORD_UNIVERSITY \
         && role == 'degree_granting_institution'
      end

      def suborganization_name
        return unless stanford_degree_granting_institution?

        contributor.name.first.structuredValue&.second&.value
      end

      def cited?
        contributor.note&.none? { |note| note.type == 'citation status' && note.value == 'false' }
      end
    end
  end
end
