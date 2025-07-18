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
      structuredValue: [
        institution_params,
        ({ value: department } if department.present?)
      ].compact
    }
  end

  def institution_params
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
