# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToCocina::Work::TypesMapper do
  subject(:forms) { described_class.call(work_form: work_form) }

  let(:work_form) { WorkForm.new }

  context 'when no types or subtypes' do
    it 'returns an empty array' do
      expect(forms).to eq([])
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
end
