# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToCocina::Work::TypesMapper do
  subject(:forms) { described_class.call(work_form:).map(&:deep_symbolize_keys) }

  let(:work_form) { WorkForm.new }

  context 'when no types or subtypes' do
    it 'returns an empty array' do
      expect(forms).to eq([])
    end
  end

  context 'when work has type and subtypes' do
    let(:work_form) do
      WorkForm.new(work_type: 'Mixed Materials', work_subtypes: ['Government document', 'Narrative film'],
                   other_work_subtype: '')
    end

    it 'maps to cocina' do
      expect(forms).to eq([
                            {
                              structuredValue: [
                                {
                                  value: 'Mixed Materials',
                                  type: 'type'
                                },
                                {
                                  value: 'Government document',
                                  type: 'subtype'
                                },
                                {
                                  value: 'Narrative film',
                                  type: 'subtype'
                                }
                              ],
                              source: {
                                value: 'Stanford self-deposit resource types'
                              },
                              type: 'resource type'
                            },
                            {
                              type: 'genre',
                              value: 'Fiction films',
                              uri: 'http://id.loc.gov/authorities/genreForms/gf2011026250',
                              source: {
                                code: 'lcgft'
                              }
                            },
                            {
                              type: 'resource type',
                              value: 'mixed material',
                              source: {
                                value: 'MODS resource types'
                              }
                            },
                            {
                              type: 'resource type',
                              value: 'moving image',
                              source: {
                                value: 'MODS resource types'
                              }
                            },
                            {
                              value: 'Collection',
                              source: {
                                value: 'DataCite resource types'
                              },
                              type: 'resource type'
                            }
                          ])
    end
  end

  context 'when Other work type' do
    let(:work_form) { WorkForm.new(work_type: 'Other', other_work_subtype: 'coloring books') }

    it 'maps to cocina' do
      expect(forms).to eq([
                            {
                              structuredValue: [
                                { value: 'Other', type: 'type' },
                                { value: 'coloring books', type: 'subtype' }
                              ],
                              source: { value: 'Stanford self-deposit resource types' },
                              type: 'resource type'
                            },
                            {
                              value: 'Other',
                              source: { value: 'DataCite resource types' },
                              type: 'resource type'
                            }
                          ])
    end
  end

  context 'when work type has multiple genres' do
    let(:work_form) { WorkForm.new(work_type: 'Data') }

    it 'maps to cocina' do
      expect(forms).to eq(
        [
          {
            structuredValue: [
              { value: 'Data', type: 'type' }
            ],
            source: { value: 'Stanford self-deposit resource types' },
            type: 'resource type'
          },
          {
            type: 'genre',
            value: 'Data sets',
            uri: 'http://id.loc.gov/authorities/genreForms/gf2018026119',
            source: { code: 'lcgft' }
          },
          {
            type: 'genre',
            value: 'dataset',
            source: { code: 'local' }
          },
          {
            type: 'resource type',
            value: 'Dataset',
            uri: 'http://id.loc.gov/vocabulary/resourceTypes/dat',
            source: { uri: 'http://id.loc.gov/vocabulary/resourceTypes/' }
          },
          {
            value: 'Dataset', source: { value: 'DataCite resource types' },
            type: 'resource type'
          }
        ]
      )
    end
  end
end
