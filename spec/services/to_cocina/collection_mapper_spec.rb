# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToCocina::CollectionMapper, type: :mapping do
  subject(:cocina_object) { described_class.call(form:, source_id: collection_source_id_fixture) }

  context 'with a new collection' do
    let(:form) { new_collection_form_fixture }

    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(request_collection_fixture)
    end
  end

  context 'with a collection' do
    let(:form) { collection_form_fixture }

    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(collection_with_metadata_fixture)
    end
  end
end
