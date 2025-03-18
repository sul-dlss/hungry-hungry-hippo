# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Roundtrippers::Collection, type: :mapping do
  subject(:validator) do
    described_class.new(collection_form: collection_form_fixture, cocina_object:)
  end

  context 'when roundtrippable' do
    let(:cocina_object) { collection_with_metadata_fixture }

    it 'returns true' do
      expect(validator.call).to be true
    end
  end

  context 'when roundtrippable but different cocina version' do
    let(:cocina_object) { collection_with_metadata_fixture.new(cocinaVersion: '0.1.1') }

    it 'returns true' do
      expect(validator.call).to be true
    end
  end

  context 'when not roundtrippable' do
    let(:cocina_object) { collection_with_metadata_fixture.new(type: Cocina::Models::ObjectType.curated_collection) }

    it 'returns false' do
      expect(validator.call).to be false
    end
  end

  context 'when cocina raises a validation error' do
    before do
      allow(ToCocina::Collection::Mapper).to receive(:call).and_raise(Cocina::Models::ValidationError)
    end

    let(:cocina_object) { collection_with_metadata_fixture }

    it 'returns false' do
      expect(validator.call).to be false
    end
  end
end
