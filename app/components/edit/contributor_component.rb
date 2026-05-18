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
             :orcid, to: :object

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
      t('form.fields.contributors.role.label')
    end

    def organization_label
      t('form.fields.contributors.organization_name.label')
    end

    def orcid_name_input_disabled?
      first_name.blank? && last_name.blank?
    end

    def collection_required?
      object.collection_required
    end

    # Nested HasMany renders a NEW_RECORD template for client-side adds.
    def template_row?
      form.options[:child_index].to_s == 'NEW_RECORD'
    end

    # Keep empty affiliation rows for template contributors on a clean form,
    # but suppress them after validation-error re-renders where specs expect
    # blank template contributors to have no nested affiliation row.
    def render_empty_affiliations?
      !(template_row? && root_form_has_errors?)
    end

    def person?
      role_type == 'person'
    end

    # This method is invoked by HasManyComponent to determine whether to render the delete button.
    def hide_delete_button?
      collection_required?
    end

    def root_form_has_errors?
      root_builder = form
      root_builder = root_builder.options[:parent_builder] while root_builder.options[:parent_builder].present?

      root_builder.object.errors.any?
    end
    private :root_form_has_errors?

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
      ['Publisher', 'publisher'],
      ['Research group', 'researcher'],
      ['Sponsor', 'sponsor']
    ].freeze
  end
end
