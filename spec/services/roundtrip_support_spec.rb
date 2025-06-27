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
      let(:original_cocina_object) { cocina_object.new(label: 'new label') }

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

      it 'returns a normalized cocina object' do
        expect(described_class.normalize_cocina_object(cocina_object:))
          .to equal_cocina dro_with_structural_and_metadata_fixture
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
