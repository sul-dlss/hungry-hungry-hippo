# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToCocina::Work::Mapper, type: :mapping do
  subject(:cocina_object) { described_class.call(work_form:, content:, source_id: source_id_fixture) }

  let(:content) { content_fixture }
  let(:work_form) { work_form_fixture }

  context 'with a new work' do
    let(:work_form) { new_work_form_fixture }
    let(:content) { new_content_fixture }

    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(request_dro_with_structural_fixture)
    end
  end

  context 'with a work' do
    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(dro_with_structural_and_metadata_fixture)
    end
  end

  context 'with a work with a hidden file' do
    let(:content) { content_fixture(hide: true) }

    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(dro_with_structural_and_metadata_fixture(hide: true))
    end
  end

  context 'with a work with a new file' do
    let(:content) { new_content_fixture }

    before do
      allow(SecureRandom).to receive(:uuid).and_return('abc123', 'bcd234')
    end

    it 'maps to cocina' do
      # The external identifiers will be different.
      expect(cocina_object.structural.contains[0].externalIdentifier).to eq 'https://cocina.sul.stanford.edu/fileSet/bc123df4567-abc123'
      expect(cocina_object.structural.contains[0].structural.contains[0].externalIdentifier).to eq 'https://cocina.sul.stanford.edu/file/bc123df4567-bcd234'
    end
  end
end