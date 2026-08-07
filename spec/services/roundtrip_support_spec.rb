# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoundtripSupport do
  include WorkMappingFixtures
  include CollectionMappingFixtures

  describe '#changed?' do
    let(:cocina_object) { dro_with_metadata_fixture }

    before do
      allow(Sdr::Repository).to receive(:find).with(druid: cocina_object.externalIdentifier).and_return(cocina_object)
    end

    context 'when the cocina object has changed' do
      let(:original_cocina_object) { cocina_object.new(version: 3) }

      it 'returns true' do
        expect(described_class.changed?(cocina_object: original_cocina_object)).to be true
      end
    end

    context 'when the cocina object has not changed' do
      it 'returns false' do
        expect(described_class.changed?(cocina_object:)).to be false
      end
    end
  end

  describe '#normalize_cocina_object' do
    context 'when the cocina object is a DRO' do
      let(:cocina_object) { dro_with_structural_and_metadata_fixture(version: 1).new(cocinaVersion: '0.0.0') }
      let(:expected_cocina_object) do
        dro_with_structural_and_metadata_fixture.new(
          # This is the deterministic form ordering.
          description: dro_fixture.description.new(form: expected_form)
        )
      end
      let(:expected_form) do
        [{ value: 'Photographs',
           type: 'genre',
           uri: 'http://id.loc.gov/authorities/genreForms/gf2017027249',
           source: { code: 'lcgft' } },
         { value: 'Data sets',
           type: 'genre',
           uri: 'http://id.loc.gov/authorities/genreForms/gf2018026119',
           source: { code: 'lcgft' } },
         { value: 'dataset',
           type: 'genre',
           source: { code: 'local' } },
         { value: 'Dataset',
           type: 'resource type',
           uri: 'http://id.loc.gov/vocabulary/resourceTypes/dat',
           source: { uri: 'http://id.loc.gov/vocabulary/resourceTypes/' } },
         { value: 'Image',
           type: 'resource type',
           source: { value: 'DataCite resource types' } },
         { value: 'still image',
           type: 'resource type',
           source: { value: 'MODS resource types' } },
         { structuredValue:
           [{ value: 'Image',
              type: 'type' },
            { value: 'Data',
              type: 'subtype' },
            { value: 'Photograph',
              type: 'subtype' }],
           type: 'resource type',
           source: { value: 'Stanford self-deposit resource types' } }]
      end

      it 'returns a normalized cocina object' do
        expect(described_class.normalize_cocina_object(cocina_object:))
          .to equal_cocina expected_cocina_object
      end
    end

    context 'when the cocina object is a Collection' do
      let(:cocina_object) { collection_with_metadata_fixture.new(cocinaVersion: '0.0.0') }

      it 'returns a normalized cocina object' do
        expect(described_class.normalize_cocina_object(cocina_object:)).to equal_cocina collection_with_metadata_fixture
      end
    end
  end
end
