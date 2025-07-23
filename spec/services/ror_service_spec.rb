# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RorService do
  subject(:organizations) { described_class.call(search:) }

  let(:search) { 'stanford' }

  context 'when the ror service returns results' do
    before do
      stub_request(:get, "https://api.ror.org/organizations?query=#{search}")
        .with(headers: { 'Accept' => 'application/json' })
        .to_return(status: 200, body:, headers: { 'Content-Type': 'application/json;charset=UTF-8' })
    end

    context 'when all fields are available' do
      let(:body) do
        {
          number_of_results: 1,
          items:
          [
            {
              id: 'https://ror.org/00f54p054',
              name: 'Stanford University',
              aliases: ['Leland Stanford Junior University, Stanford U'],
              types: ['Education'],
              country: { country_name: 'United States', country_code: 'US' },
              addresses:
                [{ lat: 37.42411,
                   lng: -122.16608,
                   state: nil,
                   state_code: nil,
                   city: 'Palo Alto' }],
              status: 'active'
            }
          ]
        }.to_json
      end

      it 'returns a successful response' do
        expect(organizations.count).to eq(1)
        expect(organizations.first.name).to eq('Stanford University')
        expect(organizations.first.id).to eq('https://ror.org/00f54p054')
        expect(organizations.first.country).to eq('United States')
        expect(organizations.first.city).to eq('Palo Alto')
        expect(organizations.first.aliases).to eq('Leland Stanford Junior University, Stanford U')
        expect(organizations.first.org_types).to eq('Education')
        expect(organizations.first.location).to eq('Palo Alto, United States')
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
              name: 'Stanford University'
            }
          ]
        }.to_json
      end

      it 'returns a successful response with only the available data' do
        expect(organizations.count).to eq(1)
        expect(organizations.first.name).to eq('Stanford University')
        expect(organizations.first.country).to be_nil
        expect(organizations.first.city).to be_nil
        expect(organizations.first.aliases).to be_nil
        expect(organizations.first.org_types).to be_nil
        expect(organizations.first.location).to eq ''
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
      stub_request(:get, "https://api.ror.org/organizations?query=#{search}")
        .with(headers: { 'Accept' => 'application/json' })
        .to_return(status: 200, body:, headers: { 'Content-Type': 'application/json;charset=UTF-8' })
    end

    it 'returns a successful but empty response' do
      expect(organizations.count).to eq(0)
    end
  end

  context 'when the ror service returns an error' do
    let(:body) { nil }

    before do
      stub_request(:get, "https://api.ror.org/organizations?query=#{search}")
        .with(headers: { 'Accept' => 'application/json' })
        .to_return(status: 404, body:, headers: { 'Content-Type': 'application/json;charset=UTF-8' })
    end

    it 'raises an error' do
      expect { organizations }.to raise_error(StandardError)
    end
  end
end
