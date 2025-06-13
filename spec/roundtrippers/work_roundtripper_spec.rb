# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkRoundtripper, type: :mapping do
  subject(:validator) do
    described_class.new(work_form: work_form_fixture, cocina_object:, content: content_fixture, notify:)
  end

  let(:notify) { true }

  context 'when roundtrippable' do
    let(:cocina_object) { dro_with_structural_and_metadata_fixture }

    it 'returns true' do
      expect(validator.call).to be true
    end
  end

  context 'when not roundtrippable' do
    let(:cocina_object) { dro_with_structural_and_metadata_fixture.new(type: Cocina::Models::ObjectType.image) }

    before do
      allow(Honeybadger).to receive(:notify)
    end

    it 'returns false' do
      expect(validator.call).to be false
      expect(Honeybadger).to have_received(:notify)
    end

    context 'with production env' do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
        allow(Rails.logger).to receive(:info)
      end

      it 'logs non-pretty json' do
        expect(validator.call).to be false
        expect(Rails.logger).to have_received(:info).with(/Roundtrip failed. Original:/).once
      end
    end

    context 'with notification disabled' do
      let(:notify) { false }

      it 'does not notify' do
        expect(validator.call).to be false
        expect(Honeybadger).not_to have_received(:notify)
      end
    end
  end
end
