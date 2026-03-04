# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrcidSupport do
  describe '.orcid_url' do
    it 'returns nil if orcid is blank' do
      expect(described_class.orcid_url('')).to be_nil
    end

    it 'returns nil if orcid is nil' do
      expect(described_class.orcid_url(nil)).to be_nil
    end

    it 'returns the full ORCID URL' do
      expect(described_class.orcid_url('0000-0000-0000-0000')).to eq('https://orcid.org/0000-0000-0000-0000')
    end
  end

  describe '.orcid_id' do
    it 'returns nil if url is blank' do
      expect(described_class.orcid_id('')).to be_nil
    end

    it 'returns nil if url is nil' do
      expect(described_class.orcid_id(nil)).to be_nil
    end

    it 'returns the ORCID identifier from the URL' do
      expect(described_class.orcid_id('https://orcid.org/0000-0000-0000-0000')).to eq('0000-0000-0000-0000')
    end
  end
end
