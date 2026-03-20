# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UriSupport do
  describe '.uri_type_for' do
    it 'returns doi for doi.org URLs' do
      expect(described_class.uri_type_for('https://doi.org/10.1126/science.aar3646')).to eq('doi')
    end

    it 'returns arxiv for arxiv.org URLs' do
      expect(described_class.uri_type_for('https://arxiv.org/abs/1706.03762')).to eq('arxiv')
    end

    it 'returns pmid for pubmed URLs' do
      expect(described_class.uri_type_for('https://pubmed.ncbi.nlm.nih.gov/31060017/')).to eq('pmid')
    end

    it 'returns nil for unrecognized URLs' do
      expect(described_class.uri_type_for('https://www.stanford.edu')).to be_nil
    end
  end
end
