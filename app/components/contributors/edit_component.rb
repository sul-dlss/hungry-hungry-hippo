# frozen_string_literal: true

module Contributors
  # Component for editing contributors
  class EditComponent < ApplicationComponent
    def initialize(form:)
      @form = form
      super()
    end

    attr_reader :form

    def role_type_options
      %w[Individual Organization]
    end

    PERSON_ROLES = [
      'Author',
      'Advisor',
      'Composer',
      'Contributing author',
      'Copyright holder',
      'Creator',
      'Data collector',
      'Data contributor',
      'Editor',
      'Event organizer',
      'Interviewee',
      'Interviewer',
      'Performer',
      'Photographer',
      'Primary thesis advisor',
      'Principal investigator',
      'Researcher',
      'Software developer',
      'Speaker',
      'Thesis advisor'
    ].freeze

    ORGANIZATION_ROLES = [
      'Author',
      'Conference',
      'Contributing author',
      'Copyright holder',
      'Data collector',
      'Data contributor',
      'Degree granting institution',
      'Distributor',
      'Event',
      'Event organizer',
      'Funder',
      'Host institution',
      'Issuing body',
      'Publisher',
      'Research group',
      'Sponsor'
    ].freeze
  end
end
