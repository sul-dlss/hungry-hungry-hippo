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
        ['Contributor', 'ORCID', 'Role', 'Include in citation?']
      end

      def values_for(contributor)
        values = [
          contributor_name(contributor).presence,
          orcid_link(contributor),
          contributor_role_label(contributor),
          helpers.human_boolean(contributor.cited)
        ]
        # Note that this excludes the cited status since it always has a value.
        return [] unless values.first(3).any?

        values
      end

      private

      def contributor_name(contributor)
        return "#{contributor.first_name} #{contributor.last_name}" if contributor.role_type == 'person'

        [contributor.suborganization_name, contributor.organization_name].compact.join(', ')
      end

      def orcid_link(contributor)
        return unless contributor.orcid

        fully_qualified_orcid_url = URI.join(Settings.orcid.url, contributor.orcid).to_s

        helpers.link_to_new_tab(fully_qualified_orcid_url) do
          concat tag.img(alt: 'ORCiD icon',
                         src: 'https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png',
                         width: 16,
                         height: 16,
                         class: 'me-2')
          concat fully_qualified_orcid_url
        end
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
