# frozen_string_literal: true

module Contributors
  # Component for editing contributors
  class EditComponent < ApplicationComponent
    def initialize(form:)
      @form = form
      super()
    end

    attr_reader :form

    def orcid
      Current.orcid
    end

    def orcid?
      orcid.present?
    end

    # Render the button to use the user's orcid if and only if the user has an
    # orcid attr in Shibboleth and hasn't already entered it
    def render_use_orcid_button?
      orcid? && (form.object.orcid.blank? || !orcid.match?(form.object.orcid))
    end

    # Render the button to reset the user's orcid if and only if the user has an
    # orcid attr in Shibboleth and *has* already entered it and it matches
    def render_reset_orcid_button?
      orcid? && form.object.orcid.present? && orcid.match?(form.object.orcid)
    end

    def contributors_data
      {
        controller: 'contributors',
        contributors_orcid_prefix_value: Settings.orcid.url,
        contributors_orcid_resolver_path_value: orcid_path(id: '')
      }.tap do |contributors_hash|
        next unless orcid?

        contributors_hash[:contributors_orcid_value] = orcid
      end
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
