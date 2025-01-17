# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToWorkForm::Mapper, type: :mapping do
  subject(:work_form) { described_class.call(cocina_object:, doi_assigned:) }

  let(:cocina_object) { dro_with_metadata_fixture }
  let(:doi_assigned) { true }

  it 'maps to work form' do
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

    it 'maps to work form' do
      expect(work_form).to equal_form(expected_work_form)
    end
  end

  context 'when default terms of use' do
    let(:cocina_object) do
      dro_with_metadata_fixture.new(access: { useAndReproductionStatement: I18n.t('license.terms_of_use') })
    end

    it 'maps to work form without custom rights statement' do
      expect(work_form.custom_rights_statement).to be_nil
    end
  end

  context 'when the DOI does not exist' do
    let(:doi_assigned) { false }

    it 'maps to work form with yes doi_option' do
      expect(work_form.doi_option).to eq('yes')
    end
  end

  context 'when cocina does not have a DOI' do
    let(:cocina_object) do
      dro_with_metadata_fixture.new(identification: { sourceId: source_id_fixture })
    end

    it 'maps to work form with no doi_option' do
      expect(work_form.doi_option).to eq('no')
    end
  end
end
