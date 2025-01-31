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
          'orcid' => orcid,
          'with_orcid' => orcid.present? }
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

        contributor.name.first.value
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
        contributor.role.first.value.sub(' ', '_')
      end
    end
  end
end
