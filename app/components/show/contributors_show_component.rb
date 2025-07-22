# frozen_string_literal: true

module Show
  # Component for rendering a table of contributors on the show page.
  class ContributorsShowComponent < ApplicationComponent
    def initialize(contributors:, presenter:, label:)
      @contributors = contributors
      @presenter = presenter
      @label = label
      super()
    end

    attr_reader :contributors, :presenter, :label

    def values_for(contributor)
      values = [
        contributor_name(contributor).presence,
        orcid_link(contributor),
        contributor_role_label(contributor),
        contributor_affiliations(contributor)
      ]

      return [] if values.all?(&:blank?)

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

    def contributor_affiliations(contributor)
      return nil if contributor.affiliations.empty?

      safe_join(contributor.affiliations.map do |affiliation|
        next if affiliation.institution.blank?

        department = affiliation.department.present? ? affiliation.department.prepend(': ') : nil

        content_tag(:p, [affiliation.institution, department].join, class: 'mb-0')
      end)
    end
  end
end
