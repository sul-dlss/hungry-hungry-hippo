# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RelatedWorksCocinaBuilder do
  subject(:related_resources) do
    described_class.call(related_works: [{ identifier:,
                                           citation:,
                                           use_citation:,
                                           relationship: }.stringify_keys])
  end

  let(:identifier) { 'https://doi.org/10.1126/science.aar3646' }
  let(:citation) { nil }
  let(:use_citation) { false }
  let(:relationship) { 'is version of' }

  context 'when DOI URI exists' do
    it 'returns the related resource' do
      expect(related_resources).to match([{
                                           type: 'has version',
                                           dataCiteRelationType: 'IsVersionOf',
                                           identifier: [{
                                             uri: 'https://doi.org/10.1126/science.aar3646',
                                             type: 'doi'
                                           }]
                                         }])
    end
  end

  context 'when arXiv URI exists' do
    let(:identifier) { 'https://arxiv.org/abs/1706.03762' }

    it 'returns the related resource' do
      expect(related_resources).to match([{
                                           type: 'has version',
                                           dataCiteRelationType: 'IsVersionOf',
                                           identifier: [{
                                             uri: 'https://arxiv.org/abs/1706.03762',
                                             type: 'arxiv'
                                           }]
                                         }])
    end
  end

  context 'when pmid URI exists' do
    let(:identifier) { 'https://pubmed.ncbi.nlm.nih.gov/31060017/' }

    it 'returns the related resource' do
      expect(related_resources).to match([{
                                           type: 'has version',
                                           dataCiteRelationType: 'IsVersionOf',
                                           identifier: [{
                                             uri: 'https://pubmed.ncbi.nlm.nih.gov/31060017/',
                                             type: 'pmid'
                                           }]
                                         }])
    end
  end

  context 'when PURL identifier exists' do
    let(:identifier) { 'https://sul-purl-stage.stanford.edu/qx938nv4212' }

    it 'returns the related resource' do
      expect(related_resources).to match([{
                                           type: 'has version',
                                           dataCiteRelationType: 'IsVersionOf',
                                           purl: 'https://sul-purl-stage.stanford.edu/qx938nv4212'
                                         }])
    end
  end

  context 'when non-URI identifier exists' do
    let(:identifier) { 'https://www.stanford.edu' }

    it 'returns the related resource' do
      expect(related_resources).to match([{
                                           type: 'has version',
                                           dataCiteRelationType: 'IsVersionOf',
                                           access: { url: [{ value: 'https://www.stanford.edu' }] }
                                         }])
    end
  end

  context 'when citation exists' do
    let(:identifier) { nil }
    let(:citation) { 'My valid citation' }
    let(:use_citation) { true }

    it 'returns the related resource' do
      expect(related_resources).to match([{
                                           type: 'has version',
                                           dataCiteRelationType: 'IsVersionOf',
                                           note: [
                                             {
                                               type: 'preferred citation',
                                               value: citation
                                             }
                                           ]
                                         }])
    end
  end
end
