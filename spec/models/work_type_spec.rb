# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkType do
  describe '.subtypes_for' do
    let(:subtypes) { described_class::IMAGE_TYPES }
    # This value is arbitrary
    let(:type) { 'Image' }

    it 'includes the extra types' do
      expect(
        described_class.subtypes_for(type)
      ).to eq(subtypes)
    end
  end
end
