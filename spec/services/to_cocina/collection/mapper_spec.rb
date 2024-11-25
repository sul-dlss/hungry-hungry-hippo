# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToCocina::Collection::Mapper, type: :mapping do
  subject(:cocina_object) { described_class.call(collection_form:, source_id: collection_source_id_fixture) }

  let(:collection_form) { collection_form_fixture }

  context 'with a new collection' do
    let(:collection_form) { new_collection_form_fixture }

    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(request_collection_fixture)
    end
  end

  context 'with a collection' do
    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(collection_with_metadata_fixture)
    end
  end
end
