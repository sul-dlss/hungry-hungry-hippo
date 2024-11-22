# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoundtripValidator, type: :mapping do
  subject(:roundtrippable?) { described_class.roundtrippable?(form:, cocina_object:, content:) }

  context 'when roundtripping a work form' do
    let(:form) { work_form_fixture }
    let(:content) { content_fixture }

    context 'when roundtrippable' do
      let(:cocina_object) { dro_with_structural_and_metadata_fixture }

      it 'returns true' do
        expect(roundtrippable?).to be true
      end
    end

    context 'when not roundtrippable' do
      let(:cocina_object) { dro_with_metadata_fixture.new(type: Cocina::Models::ObjectType.image) }

      it 'returns false' do
        expect(roundtrippable?).to be false
      end
    end
  end

  context 'when roundtripping a collection form' do
    let(:form) { collection_form_fixture }
    let(:content) { nil }

    context 'when roundtrippable' do
      let(:cocina_object) { collection_with_metadata_fixture }

      it 'returns true' do
        expect(roundtrippable?).to be true
      end
    end

    context 'when not roundtrippable' do
      let(:cocina_object) { collection_with_metadata_fixture.new(type: Cocina::Models::ObjectType.curated_collection) }

      it 'returns false' do
        expect(roundtrippable?).to be false
      end
    end
  end
end
