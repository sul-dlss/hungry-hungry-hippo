# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToWorkForm::RoundtripValidator, type: :mapping do
  subject(:roundtrippable?) { described_class.roundtrippable?(work_form:, cocina_object:) }

  context 'when roundtrippable' do
    let(:work_form) { work_form_fixture }

    let(:cocina_object) { dro_with_metadata_fixture }

    it 'returns true' do
      expect(roundtrippable?).to be true
    end
  end

  context 'when not roundtrippable' do
    let(:work_form) { work_form_fixture }

    let(:cocina_object) { dro_with_metadata_fixture.new(type: Cocina::Models::ObjectType.image) }

    it 'returns false' do
      expect(roundtrippable?).to be false
    end
  end
end