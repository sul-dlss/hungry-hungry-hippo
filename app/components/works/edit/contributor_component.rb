# frozen_string_literal: true

module Works
  module Edit
    # Component for editing contributors
    class ContributorComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form

      def user_orcid
        Current.orcid
      end

      def user_orcid?
        user_orcid.present?
      end

      def contributors_data
        {
          controller: 'contributors',
          contributors_orcid_prefix_value: Settings.orcid.url,
          contributors_orcid_resolver_path_value: orcid_path(id: '')
        }.tap do |contributors_hash|
          next unless user_orcid?

          contributors_hash[:contributors_orcid_value] = user_orcid
        end
      end

      def role_label
        'Role'
      end

      def organization_label
        'Organization name'
      end

      def orcid_name_input_disabled?
        form.object.first_name.blank? && form.object.last_name.blank?
      end

      PERSON_ROLES = [
        ['Author', 'author'],
        ['Advisor', 'advisor'],
        ['Composer', 'composer'],
        ['Contributing Author', 'contributing_author'],
        ['Copyright holder', 'copyright_holder'],
        ['Creator', 'creator'],
        ['Data collector', 'data_collector'],
        ['Data contributor', 'data_contributor'],
        ['Editor', 'editor'],
        ['Event organizer', 'event_organizer'],
        ['Interviewee', 'interviewee'],
        ['Interviewer', 'interviewer'],
        ['Performer', 'performer'],
        ['Photographer', 'photographer'],
        ['Primary thesis advisor', 'primary_thesis_advisor'],
        ['Principal investigator', 'principal_investigator'],
        ['Researcher', 'researcher'],
        ['Software developer', 'software_developer'],
        ['Speaker', 'speaker'],
        ['Thesis advisor', 'thesis_advisor']
      ].freeze

      ORGANIZATION_ROLES = [
        ['Author', 'author'],
        ['Conference', 'conference'],
        ['Contributing author', 'contributing_author'],
        ['Copyright holder', 'copyright_holder'],
        ['Data collector', 'data_collector'],
        ['Data contributor', 'data_contributor'],
        ['Degree granting institution', 'degree_granting_institution'],
        ['Distributor', 'distributor'],
        ['Event', 'event'],
        ['Event organizer', 'event_organizer'],
        ['Funder', 'funder'],
        ['Host institution', 'host_institution'],
        ['Issuing body', 'issuing_body'],
        ['Research group', 'research_group'],
        ['Sponsor', 'sponsor']
      ].freeze
    end
  end
end
