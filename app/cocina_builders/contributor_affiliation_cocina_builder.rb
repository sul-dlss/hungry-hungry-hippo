# frozen_string_literal: true

# Generates contributor affiliation for the Cocina object
class ContributorAffiliationCocinaBuilder
  def self.call(...)
    new(...).call
  end

  def initialize(institution:, uri:, department: nil)
    @department = department
    @institution = institution
    @uri = uri
  end

  attr_reader :department, :institution, :uri

  def call
    {
      type: 'affiliation',
      structuredValue: [
        generate_descriptive_value,
        ({ value: department } if department.present?)
      ].compact
    }
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
