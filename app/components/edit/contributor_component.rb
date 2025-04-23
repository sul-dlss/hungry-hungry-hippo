# frozen_string_literal: true

module Edit
  # Component for editing contributors
  class ContributorComponent < ApplicationComponent
    def initialize(form:)
      @form = form
      super()
    end

    attr_reader :form

    delegate :object, to: :form
    delegate :first_name, :last_name, :organization_name, :person_role, :organization_role,
             :stanford_degree_granting_institution, :suborganization_name, :role_type, :with_orcid,
             :orcid, :cited, to: :object

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
      first_name.blank? && last_name.blank?
    end

    def collection_required?
      object.collection_required
    end

    def person?
      role_type == 'person'
    end

    # This method is invoked by RepeatableNestedComponent to determine whether to render the delete button.
    def hide_repeatable_nested_delete_button?
      collection_required?
    end

    PERSON_ROLES = [
      ['Author', 'author'],
      ['Advisor', 'advisor'],
      ['Composer', 'composer'],
      ['Contributing author', 'contributing_author'],
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

    def orcid_aria
      Elements::Forms::InvalidFeedbackSupport.arias_for(form:, field_name: :orcid)
    end

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
      ['Research group', 'researcher'],
      ['Sponsor', 'sponsor']
    ].freeze
  end
end
