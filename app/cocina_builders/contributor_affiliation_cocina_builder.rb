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
    return institution_params if department.blank?

    {
      structuredValue: [
        institution_params,
        { value: department }
      ]
    }
  end

  def institution_params
    {
      value: institution
    }.tap do |params|
      if uri.present?
        params[:identifier] = [
          {
            uri:,
            type: 'ROR',
            source: { code: 'ror' }
          }
        ]
      end
    end
  end
end
