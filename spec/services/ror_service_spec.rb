# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RorService do
  subject(:organizations) { described_class.call(search:) }

  let(:search) { 'stanford' }
  let(:headers) do
    { 'Accept' => 'application/json',
      'User-Agent' => 'Stanford Self-Deposit (Hungry Hungry Hippo)',
      'Client-Id' => Settings.ror.client_id }
  end

  context 'when the ror service returns results' do
    before do
      stub_request(:get, "https://api.ror.org/v2/organizations?query=#{search}")
        .with(headers:)
        .to_return(status: 200, body:, headers: { 'Content-Type': 'application/json;charset=UTF-8' })
    end

    context 'when all fields are available' do
      let(:body) do
        {
          number_of_results: 1,
          items: [
            {
              id: 'https://ror.org/00f54p054',
              names: [
                {
                  lang: 'en',
                  value: 'Stanford University',
                  types: %w[ror_display label]
                },
                {
                  lang: 'en',
                  value: 'Leland Stanford Junior University',
                  types: %w[alias]
                }
              ],
              types: ['Education'],
              locations: [
                {
                  geonames_details: {
                    country_code: 'US',
                    country_name: 'United States',
                    name: 'Stanford',
                    lat: 37.42411,
                    lng: -122.16608
                  }
                }
              ],
              status: 'active'
            }
          ]
        }.to_json
      end

      it 'returns a successful response' do
        expect(organizations.count).to eq(1)
        expect(organizations.first.name).to eq('Stanford University')
        expect(organizations.first.id).to eq('https://ror.org/00f54p054')
        expect(organizations.first.location).to eq('Stanford, United States')
        expect(organizations.first.aliases).to eq('Leland Stanford Junior University')
        expect(organizations.first.org_types).to eq('Education')
      end
    end

    context 'when there is only minimal data' do
      let(:body) do
        {
          number_of_results: 1,
          items:
          [
            {
              id: 'https://ror.org/00f54p054',
              names: [
                {
                  lang: 'en',
                  value: 'Stanford University',
                  types: %w[ror_display label]
                }
              ]
            }
          ]
        }.to_json
      end

      it 'returns a successful response with only the available data' do
        expect(organizations.count).to eq(1)
        expect(organizations.first.name).to eq('Stanford University')
        expect(organizations.first.aliases).to eq ''
        expect(organizations.first.org_types).to be_nil
        expect(organizations.first.location).to be_nil
      end
    end
  end

  context 'when the ror service returns no results' do
    let(:body) do
      {
        number_of_results: 0,
        items: []
      }.to_json
    end

    before do
      stub_request(:get, "https://api.ror.org/v2/organizations?query=#{search}")
        .with(headers:)
        .to_return(status: 200, body:, headers: { 'Content-Type': 'application/json;charset=UTF-8' })
    end

    it 'returns a successful but empty response' do
      expect(organizations.count).to eq(0)
    end
  end

  context 'when the ror service returns an error' do
    let(:body) { nil }

    before do
      stub_request(:get, "https://api.ror.org/v2/organizations?query=#{search}")
        .with(headers:)
        .to_return(status: 404, body:, headers: { 'Content-Type': 'application/json;charset=UTF-8' })
    end

    it 'raises an error' do
      expect { organizations }.to raise_error(StandardError)
    end
  end
end
