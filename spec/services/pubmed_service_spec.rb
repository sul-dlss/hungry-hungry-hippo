# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PubmedService do
  subject(:pubmed_search) { described_class.call(search:) }

  let(:status) { 200 }

  let(:headers) do
    {
      'Accept' => 'application/json',
      'User-Agent' => 'Stanford Self-Deposit (Hungry Hungry Hippo)'
    }
  end
  let(:tool) { 'stanford_sdr_h3' }
  let(:base_url) { "#{Settings.pubmed.url}/tools/idconv/api/v1/articles/" }
  let(:query) do
    {
      email: Settings.pubmed.email,
      format: 'json',
      ids: search,
      tool:
    }
  end

  before do
    stub_request(:get, base_url)
      .with(headers:, query:)
      .to_return(status:, body: pubmed_response, headers: { 'Content-Type': 'application/json;charset=UTF-8' })
  end

  context 'when the search is successful and returns a DOI' do
    let(:search) { 'PMC3531190' }
    let(:doi) { '10.1093/nar/gks1195' }

    let(:pubmed_response) do
      {
        status: 'ok',
        response_date: '2026-02-18 17:33:07',
        request: {
          warnings: [],
          format: 'json',
          ids: [search],
          email: Settings.pubmed.email,
          tool:,
          echo: "ids=#{search}&format=json&tool=#{tool}&email=#{Settings.pubmed.email}",
          versions: 'no',
          showaiid: 'no',
          idtype: 'pmcid'
        },
        records: [
          {
            doi:,
            pmcid: search,
            pmid: '23193287',
            'requested-id': search
          }
        ]
      }.to_json
    end

    it 'returns the DOI from the first record' do
      expect(pubmed_search).to eq(doi)
    end
  end

  context 'when the response status is not ok' do
    let(:search) { 'INVALID' }

    let(:pubmed_response) do
      {
        status: 'error',
        response_date: '2026-02-18 17:33:07',
        request: {
          ids: [search],
          format: 'json',
          tool:,
          email: Settings.pubmed.email
        },
        error: 'Invalid request'
      }.to_json
    end

    it 'raises not found error' do
      expect { pubmed_search }.to raise_exception(PubmedService::Error)
    end
  end

  context 'when the records array is empty' do
    let(:search) { 'PMC9999999' }

    let(:pubmed_response) do
      {
        status: 'ok',
        response_date: '2026-02-18 17:33:07',
        request: {
          ids: [search],
          format: 'json',
          tool:,
          email: Settings.pubmed.email
        },
        records: []
      }.to_json
    end

    it 'raises not found error' do
      expect { pubmed_search }.to raise_exception(PubmedService::NotFound)
    end
  end

  context 'when the first record does not have a DOI' do
    let(:search) { 'PMC3531191' }

    let(:pubmed_response) do
      {
        status: 'ok',
        response_date: '2026-02-18 17:33:07',
        request: {
          ids: [search],
          format: 'json',
          tool:,
          email: Settings.pubmed.email
        },
        records: [
          {
            pmcid: search,
            pmid: 23_193_287,
            'requested-id': search
          }
        ]
      }.to_json
    end

    it 'raises not found error' do
      expect { pubmed_search }.to raise_exception(PubmedService::NotFound)
    end
  end

  context 'when pubmed API returns a server error' do
    let(:search) { 'PMC3531190' }
    let(:status) { 500 }
    let(:pubmed_response) { {}.to_json }

    it 'raises general error' do
      expect { pubmed_search }.to raise_exception(PubmedService::Error)
    end
  end
end
