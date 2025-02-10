# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoundtripSupport do
  include WorkMappingFixtures

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
end
