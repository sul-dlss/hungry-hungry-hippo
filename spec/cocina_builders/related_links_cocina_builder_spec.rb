# frozen_string_literal: true

require 'rails_helper'

# related links builder is for collections only
RSpec.describe RelatedLinksCocinaBuilder do
  subject(:related_links) do
    described_class.call(related_links: [{ url:, text: }.stringify_keys])
  end

  let(:url) { 'https://doi.org/10.1126/science.aar3646' }
  let(:text) { 'A Link' }

  context 'when DOI URI exists' do
    it 'returns the link' do
      expect(related_links).to match([{ title: [{ value: text }],
                                        identifier: [{
                                          uri: 'https://doi.org/10.1126/science.aar3646',
                                          type: 'doi'
                                        }] }])
    end
  end

  context 'when arXiv URI exists' do
    let(:url) { 'https://arxiv.org/abs/1706.03762' }

    it 'returns the related resource' do
      expect(related_links).to match([{
                                       title: [{ value: text }],
                                       identifier: [{
                                         uri: 'https://arxiv.org/abs/1706.03762',
                                         type: 'arxiv'
                                       }]
                                     }])
    end
  end

  context 'when pmid URI exists' do
    let(:url) { 'https://pubmed.ncbi.nlm.nih.gov/31060017/' }

    it 'returns the related resource' do
      expect(related_links).to match([{ title: [{ value: text }],
                                        identifier: [{
                                          uri: 'https://pubmed.ncbi.nlm.nih.gov/31060017/',
                                          type: 'pmid'
                                        }] }])
    end
  end

  context 'when PURL identifier exists' do
    let(:url) { 'https://sul-purl-stage.stanford.edu/qx938nv4212' }

    it 'returns the related resource' do
      expect(related_links).to match([{
                                       title: [{ value: text }],
                                       purl: 'https://sul-purl-stage.stanford.edu/qx938nv4212'
                                     }])
    end
  end

  context 'when non-URI identifier exists' do
    let(:url) { 'https://www.stanford.edu' }

    it 'returns the related resource' do
      expect(related_links).to match([{
                                       title: [{ value: text }],
                                       access: { url: [{ value: 'https://www.stanford.edu' }] }
                                     }])
    end
  end
end
