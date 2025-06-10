# frozen_string_literal: true

# Generates the Cocina contributor parameters for an organization
class OrganizationContributorCocinaBuilder
  def self.call(...)
    new(...).call
  end

  # @param name [String] the name of the organization
  # @param role [String] the role of the organization from ROLES
  # @param suborganization_name [String] the name of the suborganization (e.g., department)
  # @param primary [Boolean] whether this is the first contributor
  def initialize(name:, role:, suborganization_name: nil, primary: false)
    @name = name
    @suborganization_name = suborganization_name
    @role = role
    @primary = primary
  end

  def call
    if stanford_degree_granting_institution? && suborganization_name.present?
      stanford_with_suborganization_params
    else
      organization_params
    end
  end

  private

  attr_reader :name, :role, :primary, :suborganization_name

  def organization_params
    {
      name: [{ value: name }],
      type: contributor_type,
      role: role_params,
      status: status_value,
      identifier: identifier_params
    }.compact
  end

  def stanford_with_suborganization_params
    {
      name: [{
        structuredValue: [
          {
            value: WorkForm::STANFORD_UNIVERSITY,
            identifier: identifier_params
          },
          { value: suborganization_name }
        ]
      }],
      type: contributor_type,
      role: role_params,
      status: status_value
    }.compact
  end

  def stanford_degree_granting_institution?
    name == WorkForm::STANFORD_UNIVERSITY && role == 'degree_granting_institution'
  end

  def status_value
    primary ? 'primary' : nil
  end

  def role_params
    cocina_role = ContributorRoleCocinaBuilder.call(role:)
    return if cocina_role.nil?

    [cocina_role]
  end

  def contributor_type
    return role if %w[event conference].include?(role)

    'organization'
  end

  def identifier_params
    return unless stanford_degree_granting_institution?

    [
      {
        uri: 'https://ror.org/00f54p054',
        type: 'ROR',
        source: {
          code: 'ror'
        }
      }
    ]
  end
end
