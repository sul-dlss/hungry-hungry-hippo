# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToWorkForm::Mapper, type: :mapping do
  subject(:work_form) { described_class.call(cocina_object:) }

  let(:cocina_object) { dro_with_metadata_fixture }

  it 'maps to cocina' do
    expect(work_form).to equal_form(work_form_fixture)
  end

  context 'when Other work type' do
    let(:cocina_object) do
      dro_with_metadata_fixture.then do |object|
        object.new(
          object
            .to_h
            .tap do |obj|
            obj[:description][:form] = [
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
            ]
          end
        )
      end
    end

    let(:expected_work_form) do
      work_form_fixture.tap do |work_form|
        work_form.work_type = 'Other'
        work_form.other_work_subtype = 'coloring books'
        work_form.work_subtypes = []
      end
    end

    it 'maps to cocina' do
      expect(work_form).to equal_form(expected_work_form)
    end
  end
end
