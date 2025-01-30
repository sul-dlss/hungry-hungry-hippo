# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaParsers::Description do
  include WorkMappingFixtures

  describe '#title_for' do
    let(:cocina_object) { build(:dro, title: title_fixture) }

    it 'returns the title' do
      expect(described_class.title(cocina_object:)).to eq title_fixture
    end
  end
end
