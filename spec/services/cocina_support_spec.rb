# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaSupport do
  describe '#title_for' do
    let(:cocina_object) { build(:dro) }

    it 'returns the title' do
      expect(described_class.title_for(cocina_object: cocina_object)).to eq 'factory DRO title'
    end
  end
end
