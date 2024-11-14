# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaSupport do
  describe '#title_for' do
    let(:cocina_object) { build(:dro, title: title_fixture) }

    it 'returns the title' do
      expect(described_class.title_for(cocina_object:)).to eq title_fixture
    end
  end
end
