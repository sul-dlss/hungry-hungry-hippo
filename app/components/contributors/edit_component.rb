# frozen_string_literal: true

module Contributors
  # Component for editing contributors
  class EditComponent < ApplicationComponent
    def initialize(form:)
      @form = form
      super()
    end

    attr_reader :form

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
      ['Publisher', 'publisher'],
      ['Research group', 'research_group'],
      ['Sponsor', 'sponsor']
    ].freeze
  end
end
