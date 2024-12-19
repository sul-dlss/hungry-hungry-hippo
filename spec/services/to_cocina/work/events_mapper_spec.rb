# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToCocina::Work::EventsMapper do
  describe 'publication events' do
    subject(:events) { described_class.call(work_form:) }

    let(:authors_attributes) do
      authors_fixture +
        [
          {
            'role_type' => 'organization',
            'person_role' => nil,
            'organization_role' => 'publisher',
            'with_orcid' => false,
            'orcid' => nil,
            'first_name' => nil,
            'last_name' => nil,
            'organization_name' => 'Stanford University Press'
          }
        ]
    end

    let(:publication_date_attributes) { { year: 2021, month: 1, day: 11 } }

    let(:expected_date_params) do
      [
        {
          value: '2021-01-11',
          type: 'publication',
          encoding: { code: 'edtf' },
          status: 'primary'
        }
      ]
    end

    let(:expected_contributor_params) do
      [
        {
          name: [
            {
              value: 'Stanford University Press'
            }
          ],
          type: 'organization',
          role: [
            {
              value: 'publisher',
              code: 'pbl',
              uri: 'http://id.loc.gov/vocabulary/relators/pbl',
              source: {
                code: 'marcrelator',
                uri: 'http://id.loc.gov/vocabulary/relators/'
              }
            }
          ]
        }
      ]
    end

    context 'when no publication date' do
      let(:work_form) { WorkForm.new }

      it 'returns an empty array' do
        expect(events).to eq([])
      end
    end

    context 'when publication date' do
      let(:work_form) { WorkForm.new(publication_date_attributes:) }

      it 'maps to cocina' do
        expect(events).to eq([
                               {
                                 type: 'publication',
                                 date: expected_date_params
                               }
                             ])
      end
    end

    context 'when publisher' do
      let(:work_form) { WorkForm.new(authors_attributes:) }

      it 'maps to cocina' do
        expect(events).to eq([
                               {
                                 type: 'publication',
                                 contributor: expected_contributor_params
                               }
                             ])
      end
    end

    context 'when publisher and publication date' do
      let(:work_form) { WorkForm.new(publication_date_attributes:, authors_attributes:) }

      it 'maps to cocina' do
        expect(events).to eq([
                               {
                                 type: 'publication',
                                 date: expected_date_params,
                                 contributor: expected_contributor_params
                               }
                             ])
      end
    end
  end
end
