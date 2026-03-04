# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DoiSupport do
  describe '.identifier' do
    it 'returns nil if the DOI is blank' do
      expect(described_class.identifier('')).to be_nil
    end

    it 'returns the DOI without the https://doi.org/ prefix' do
      expect(described_class.identifier('https://doi.org/10.1234/abcd')).to eq('10.1234/abcd')
    end

    it 'returns the DOI unchanged if it does not have the prefix' do
      expect(described_class.identifier('10.1234/abcd')).to eq('10.1234/abcd')
    end
  end
end
