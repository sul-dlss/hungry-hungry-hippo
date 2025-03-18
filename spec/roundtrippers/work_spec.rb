# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Roundtrippers::Work, type: :mapping do
  subject(:validator) do
    described_class.new(work_form: work_form_fixture, cocina_object:, content: content_fixture)
  end

  context 'when roundtrippable' do
    let(:cocina_object) { dro_with_structural_and_metadata_fixture }

    it 'returns true' do
      expect(validator.call).to be true
    end
  end

  context 'when not roundtrippable' do
    let(:cocina_object) { dro_with_structural_and_metadata_fixture.new(type: Cocina::Models::ObjectType.image) }

    it 'returns false' do
      expect(validator.call).to be false
    end

    context 'with production env' do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
        allow(Rails.logger).to receive(:info)
      end

      it 'logs non-pretty json' do
        validator.call
        expect(Rails.logger).to have_received(:info).with(/Roundtrip failed. Original:/).once
      end
    end
  end
end
