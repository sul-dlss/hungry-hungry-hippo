# frozen_string_literal: true

module Works
  module Show
    # Component for rendering a table of authors on the work show page.
    class AuthorsShowComponent < ApplicationComponent
      def initialize(work:)
        @work = work
        super()
      end

      attr_reader :work

      def headers
        %w[Authors ORCID Role]
      end

      def values_for(author)
        [
          author_name(author),
          orcid_link(author),
          author_role_label(author)
        ]
      end

      private

      def author_name(author)
        return "#{author.first_name} #{author.last_name}" if author.role_type == 'person'

        author.organization_name
      end

      def orcid_link(author)
        return unless author.orcid

        link_to(author.orcid, author.orcid, target: '_blank', rel: 'noopener')
      end

      def author_role_label(author)
        return unless author.person_role || author.organization_role

        author_role(author).sub('_', ' ').capitalize
      end

      def author_role(author)
        return author.person_role if author.role_type == 'person'

        author.organization_role
      end
    end
  end
end
