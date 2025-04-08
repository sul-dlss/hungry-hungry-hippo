# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationContributorCocinaBuilder do
  context 'with conference role' do
    subject(:cocina_params) { described_class.call(name: 'RailsConf', role: 'conference') }

    it 'creates Cocina::Models::Contributor params without marc relator role' do
      expect(cocina_params).to eq(
        {
          name: [{ value: 'RailsConf' }],
          type: 'conference',
          role: [
            {
              value: 'conference'
            }
          ]
        }
      )
    end
  end

  context 'with Stanford University as degree_granting_institution' do
    subject(:cocina_params) { described_class.call(name: 'Stanford University', role: 'degree_granting_institution') }

    it 'creates Cocina::Models::Contributor params with ROR identifier' do
      expect(cocina_params).to eq(
        {
          name: [{ value: 'Stanford University' }],
          type: 'organization',
          role: [
            {
              value: 'degree granting institution',
              code: 'dgg',
              uri: 'http://id.loc.gov/vocabulary/relators/dgg',
              source: {
                code: 'marcrelator',
                uri: 'http://id.loc.gov/vocabulary/relators/'
              }
            }
          ],
          identifier: [
            {
              uri: 'https://ror.org/00f54p054',
              type: 'ROR',
              source: {
                code: 'ror'
              }
            }
          ]
        }
      )
    end
  end

  context 'with Stanford University as degree_granting_institution and a suborganization' do
    subject(:cocina_params) do
      described_class.call(name: 'Stanford University', role: 'degree_granting_institution',
                           suborganization_name: 'Woods Institute for the Environment')
    end

    it 'creates Cocina::Models::Contributor params with structured value' do
      expect(cocina_params).to eq(
        {
          name: [
            {
              structuredValue: [
                {
                  value: 'Stanford University',
                  identifier: [
                    {
                      uri: 'https://ror.org/00f54p054',
                      type: 'ROR',
                      source: {
                        code: 'ror'
                      }
                    }
                  ]
                },
                {
                  value: 'Woods Institute for the Environment'
                }
              ]
            }
          ],
          type: 'organization',
          role: [
            {
              value: 'degree granting institution',
              code: 'dgg',
              uri: 'http://id.loc.gov/vocabulary/relators/dgg',
              source: {
                code: 'marcrelator',
                uri: 'http://id.loc.gov/vocabulary/relators/'
              }
            }
          ]
        }
      )
    end
  end

  context 'with other degree_granting_institution' do
    subject(:cocina_params) do
      described_class.call(name: 'Foothill College', role: 'degree_granting_institution')
    end

    it 'creates Cocina::Models::Contributor params without ROR identifier' do
      expect(cocina_params).to eq(
        {
          name: [{ value: 'Foothill College' }],
          type: 'organization',
          role: [
            {
              value: 'degree granting institution',
              code: 'dgg',
              uri: 'http://id.loc.gov/vocabulary/relators/dgg',
              source: {
                code: 'marcrelator',
                uri: 'http://id.loc.gov/vocabulary/relators/'
              }
            }
          ]
        }
      )
    end
  end

  context 'when not cited' do
    subject(:cocina_params) { described_class.call(name: 'Stanford University', role: 'creator', cited: false) }

    it 'creates Cocina::Models::Contributor params with note' do
      expect(cocina_params).to eq(
        {
          name: [{ value: 'Stanford University' }],
          type: 'organization',
          role: [
            {
              value: 'creator',
              code: 'cre',
              uri: 'http://id.loc.gov/vocabulary/relators/cre',
              source: {
                code: 'marcrelator',
                uri: 'http://id.loc.gov/vocabulary/relators/'
              }
            }
          ],
          note: [
            {
              type: 'citation status',
              value: 'false'
            }
          ]
        }
      )
    end
  end
end
