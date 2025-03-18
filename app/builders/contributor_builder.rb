# frozen_string_literal: true

# Builds a contributor form from the Contributor AR model
class ContributorBuilder
  def self.call(...)
    new(...).call
  end

  def initialize(contributor:)
    @contributor = contributor
  end

  def call
    if contributor.person?
      person_attributes
    else
      organization_attributes
    end
  end

  private

  attr_reader :contributor

  def person_attributes
    contributor.attributes.slice('first_name', 'last_name', 'role_type', 'orcid',
                                 'cited').symbolize_keys.tap do |attributes|
      attributes[:person_role] = contributor.role
      attributes[:with_orcid] = contributor.orcid.present?
      attributes[:stanford_degree_granting_institution] = false
    end
  end

  def organization_attributes
    contributor.attributes.slice('organization_name', 'role_type', 'cited',
                                 'suborganization_name').symbolize_keys.tap do |attributes|
      attributes[:organization_role] = contributor.role
      attributes[:stanford_degree_granting_institution] =
        contributor.role == 'degree_granting_institution' && contributor.organization_name == 'Stanford University'
      attributes[:with_orcid] = false
    end
  end
end
