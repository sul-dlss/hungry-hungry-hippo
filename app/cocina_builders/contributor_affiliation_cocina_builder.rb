# frozen_string_literal: true

# Generates contributor affiliation for the Cocina object
class ContributorAffiliationCocinaBuilder
  SOURCE = {
    code: 'marcrelator',
    uri: 'http://id.loc.gov/vocabulary/relators/'
  }.freeze

  def self.call(...)
    new(...).call
  end

  def initialize(department:, institution:, uri:)
    @department = department
    @institution = institution
    @uri = uri
  end

  attr_reader :department, :institution, :uri

  def call
    {}.tap do |affiliation|
      affiliation[:type] = 'affiliation'
      affiliation[:structuredValue] = [
        generate_descriptive_value,
        { value: department }
      ].compact_blank
    end
  end

  def generate_descriptive_value
    {
      value: institution,
      identifier: [
        {
          uri:,
          type: 'ROR',
          source: { code: 'ror' }
        }
      ]
    }
  end
end
