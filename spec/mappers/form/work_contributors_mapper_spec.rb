# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::WorkContributorsMapper do
  subject(:contributor_params) { described_class.call(cocina_object:) }

  let(:cocina_object) do
    dro = build(:dro)
    dro.new(description: dro.description.new(contributor: [cocina_contributor_params]))
  end

  context 'when a person' do
    let(:cocina_contributor_params) do
      {
        name: [
          {
            structuredValue: [
              { value: 'Jane', type: 'forename' },
              { value: 'Stanford', type: 'surname' }
            ]
          }
        ],
        type: 'person',
        status: 'primary',
        identifier: [
          {
            type: 'ORCID',
            value: '0000-0000-0000-0000',
            source: {
              uri: 'https://orcid.org'
            }
          }
        ],
        note: [
          {
            type: 'affiliation',
            structuredValue: [
              {
                value: 'Stanford University',
                identifier: [
                  {
                    type: 'ROR',
                    uri: 'https://ror.org/01abcd',
                    source: { code: 'ror' }
                  }
                ]
              },
              { value: 'Department of History' }
            ]
          }
        ]
      }
    end

    it 'maps to contributor params' do
      expect(contributor_params).to eq([
                                         'first_name' => 'Jane',
                                         'last_name' => 'Stanford',
                                         'role_type' => 'person',
                                         'person_role' => nil,
                                         'organization_role' => nil,
                                         'organization_name' => nil,
                                         'suborganization_name' => nil,
                                         'stanford_degree_granting_institution' => false,
                                         'orcid' => '0000-0000-0000-0000',
                                         'with_orcid' => true,
                                         'affiliations_attributes' => [
                                           {
                                             'institution' => 'Stanford University',
                                             'uri' => 'https://ror.org/01abcd',
                                             'department' => 'Department of History'
                                           }
                                         ]
                                       ])
    end
  end

  context 'when role is absent' do
    let(:cocina_contributor_params) do
      {
        name: [{ value: 'NASA' }],
        type: 'organization',
        status: 'primary'
      }
    end

    it 'maps to contributor params' do
      expect(contributor_params).to eq([
                                         'first_name' => nil,
                                         'last_name' => nil,
                                         'role_type' => 'organization',
                                         'person_role' => nil,
                                         'organization_role' => nil,
                                         'organization_name' => 'NASA',
                                         'suborganization_name' => nil,
                                         'stanford_degree_granting_institution' => false,
                                         'orcid' => nil,
                                         'with_orcid' => false,
                                         'affiliations_attributes' => []
                                       ])
    end
  end

  context 'when conference' do
    let(:cocina_contributor_params) do
      {
        name: [{ value: 'NASA conference' }],
        role: [{ value: 'conference' }],
        type: 'conference',
        status: 'primary'
      }
    end

    it 'maps to contributor params' do
      expect(contributor_params).to eq([
                                         'first_name' => nil,
                                         'last_name' => nil,
                                         'role_type' => 'organization',
                                         'person_role' => nil,
                                         'organization_role' => 'conference',
                                         'organization_name' => 'NASA conference',
                                         'suborganization_name' => nil,
                                         'stanford_degree_granting_institution' => false,
                                         'orcid' => nil,
                                         'with_orcid' => false,
                                         'affiliations_attributes' => []
                                       ])
    end
  end

  context 'when event' do
    let(:cocina_contributor_params) do
      {
        name: [{ value: 'NASA event' }],
        role: [{ value: 'event' }],
        type: 'event',
        status: 'primary'
      }
    end

    it 'maps to contributor params' do
      expect(contributor_params).to eq([
                                         'first_name' => nil,
                                         'last_name' => nil,
                                         'role_type' => 'organization',
                                         'person_role' => nil,
                                         'organization_role' => 'event',
                                         'organization_name' => 'NASA event',
                                         'suborganization_name' => nil,
                                         'stanford_degree_granting_institution' => false,
                                         'orcid' => nil,
                                         'with_orcid' => false,
                                         'affiliations_attributes' => []
                                       ])
    end
  end
end
