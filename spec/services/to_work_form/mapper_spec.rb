# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToWorkForm::Mapper, type: :mapping do
  subject(:work_form) do
    described_class.call(cocina_object:, doi_assigned:, agree_to_terms: true,
                         version_description: whats_changing_fixture, collection:)
  end

  let(:cocina_object) { dro_with_metadata_fixture }
  let(:collection) { create(:collection, :with_required_contact_email, druid: collection_druid_fixture) }
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

  context 'when blank work subtype' do
    # There is some legacy data with blank work subtypes. This tests that it will be handled.
    let(:cocina_object) do
      dro_with_metadata_fixture.then do |object|
        object.new(
          object
            .to_h
            .tap do |obj|
            obj[:description][:form] = [
              {
                structuredValue: [
                  {
                    value: 'Image',
                    type: 'type'
                  },
                  {
                    value: 'CAD',
                    type: 'subtype'
                  },
                  {
                    value: 'Map',
                    type: 'subtype'
                  },
                  {
                    type: 'subtype',
                    value: ''
                  }
                ],
                type: 'resource type',
                source: {
                  value: 'Stanford self-deposit resource types'
                }
              },
              {
                value: 'Computer-aided designs',
                type: 'genre',
                uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm002405',
                source: {
                  code: 'lctgm'
                }
              },
              {
                value: 'Maps',
                type: 'genre',
                uri: 'http://id.loc.gov/authorities/genreForms/gf2011026387',
                source: {
                  code: 'lcgft'
                }
              },
              {
                value: 'still image',
                type: 'resource type',
                source: {
                  value: 'MODS resource types'
                }
              },
              {
                value: 'cartographic',
                type: 'resource type',
                source: {
                  value: 'MODS resource types'
                }
              },
              {
                value: 'Image',
                type: 'resource type',
                source: {
                  value: 'DataCite resource types'
                }
              }
            ]
          end
        )
      end
    end

    it 'maps to work form' do
      expect(work_form).to equal_form(work_form_fixture)
    end
  end

  context 'when no types' do
    let(:cocina_object) do
      dro_with_metadata_fixture.then do |object|
        object.new(
          object
            .to_h
            .tap do |obj|
            obj[:description][:form] = []
          end
        )
      end
    end

    let(:expected_work_form) do
      work_form_fixture.tap do |work_form|
        work_form.work_type = nil
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

  context 'when cocina does not have a license' do
    let(:cocina_object) do
      dro_with_metadata_fixture.new(access: dro_with_metadata_fixture.access.new(license: nil))
    end

    it 'maps to work form with no doi_option' do
      expect(work_form.license).to eq('no-license')
    end
  end

  context 'when collection declares a required contact email' do
    it 'maps the value to its own form field, not the contact emails field' do
      expect(work_form.contact_emails.map(&:email)).not_to include(works_contact_email_fixture)
      expect(work_form.works_contact_email).to eq(works_contact_email_fixture)
    end
  end
end
