# frozen_string_literal: true

# Generates contributor affiliations for the Cocina object
class ContributorAffiliationsCocinaBuilder
  SOURCE = {
    code: 'marcrelator',
    uri: 'http://id.loc.gov/vocabulary/relators/'
  }.freeze

  def self.call(...)
    new(...).call
  end

  def initialize(affiliations:)
    @affiliations = affiliations
  end

  attr_reader :affiliations

  def call
    return if affiliations.nil?

    affiliations.map do |affiliation|
      {
        type: 'affiliation',
        structuredValue: [
          {
            value: affiliation.institution,
            identifier: [
              {
                uri: affiliation.uri,
                type: 'ROR',
                source: { code: 'ror' }
              }
            ]
          },
          {
            value: affiliation.department
          }
        ].compact
      }.compact
    end
  end
end
