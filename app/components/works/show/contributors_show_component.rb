# frozen_string_literal: true

module Works
  module Show
    # Component for rendering a table of contributors on the work show page.
    class ContributorsShowComponent < ApplicationComponent
      def initialize(contributors:, work_presenter:)
        @contributors = contributors
        @work_presenter = work_presenter
        super()
      end

      attr_reader :contributors, :work_presenter

      def headers
        %w[Contributor ORCID Role]
      end

      def values_for(contributor)
        values = [
          contributor_name(contributor).presence,
          orcid_link(contributor),
          contributor_role_label(contributor)
        ]
        return [] unless values.any?

        values
      end

      private

      def contributor_name(contributor)
        return "#{contributor.first_name} #{contributor.last_name}" if contributor.role_type == 'person'

        [contributor.suborganization_name, contributor.organization_name].compact.join(', ')
      end

      def orcid_link(contributor)
        return unless contributor.orcid

        helpers.link_to_new_tab(contributor.orcid, contributor.orcid)
      end

      def contributor_role_label(contributor)
        return unless contributor.person_role || contributor.organization_role

        contributor_role(contributor).tr('_', ' ').capitalize
      end

      def contributor_role(contributor)
        return contributor.person_role if contributor.role_type == 'person'

        contributor.organization_role
      end
    end
  end
end
