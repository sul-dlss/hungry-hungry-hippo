# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkType do
  describe '.subtypes_for' do
    let(:subtypes) { described_class::IMAGE_TYPES }
    # This value is arbitrary
    let(:type) { 'image' }

    context 'with more types arg' do
      it 'includes the extra types' do
        expect(
          described_class.subtypes_for(type, include_more_types: true)
        ).to eq(subtypes + described_class.more_types)
      end
    end

    context 'without more types arg' do
      it 'defaults to excluding the extra types' do
        expect(
          described_class.subtypes_for(type)
        ).to eq(subtypes)
      end
    end
  end
end
