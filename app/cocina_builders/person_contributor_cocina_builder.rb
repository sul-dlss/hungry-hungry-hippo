# frozen_string_literal: true

# Generates the Cocina contributor parameters for a person
class PersonContributorCocinaBuilder
  def self.call(...)
    new(...).call
  end

  # @param surname [String] the surname of the person
  # @param forename [String] the forename of the person
  # @param role [String] the role of the person from ROLES
  # @param primary [Boolean] whether this is the first contributor
  # @param orcid [String] the ORCID of the person
  # @param affiliations [Array<Hash>] the affiliations of the person (:institution, :uri, :department (optional))
  def initialize(surname:, forename:, role:, primary: false, orcid: nil, affiliations: []) # rubocop:disable Metrics/ParameterLists
    @surname = surname
    @forename = forename
    @role = role
    @primary = primary
    @orcid = orcid
    @affiliations = affiliations
  end

  def call
    {
      name: [
        {
          structuredValue: [
            { value: forename, type: 'forename' },
            { value: surname, type: 'surname' }
          ]
        }
      ],
      type: 'person',
      role: role_params,
      identifier: identifier_params,
      status: ('primary' if primary),
      affiliation: affiliation_params
    }.compact
  end

  private

  attr_reader :forename, :surname, :role, :primary, :orcid, :affiliations

  def role_params
    cocina_role = ContributorRoleCocinaBuilder.call(role:)
    return if cocina_role.nil?

    [cocina_role]
  end

  def affiliation_params
    return if affiliations.empty?

    affiliations.filter_map do |affiliation|
      ContributorAffiliationCocinaBuilder.call(**form_affiliation_params(affiliation)) unless affiliation.empty?
    end.presence
  end

  def form_affiliation_params(affiliation)
    return affiliation if affiliation.is_a?(Hash)

    # return the attributes as a hash with symbolized keys if it's an AffiliationForm object
    affiliation.attributes.symbolize_keys
  end

  def identifier_params
    return if orcid.blank?

    [
      {
        value: orcid,
        type: 'ORCID',
        source: { uri: Settings.orcid.url }
      }
    ]
  end
end
