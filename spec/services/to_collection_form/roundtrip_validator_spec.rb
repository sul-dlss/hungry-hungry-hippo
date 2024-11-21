# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToCollectionForm::RoundtripValidator, type: :mapping do
  subject(:roundtrippable?) { described_class.roundtrippable?(collection_form:, cocina_object:) }

  context 'when roundtrippable' do
    let(:collection_form) { collection_form_fixture }

    let(:cocina_object) { collection_with_metadata_fixture }

    it 'returns true' do
      expect(roundtrippable?).to be true
    end
  end

  context 'when not roundtrippable' do
    let(:collection_form) { collection_form_fixture }

    let(:cocina_object) { collection_with_metadata_fixture.new(type: Cocina::Models::ObjectType.curated_collection) }

    it 'returns false' do
      expect(roundtrippable?).to be false
    end
  end
end
