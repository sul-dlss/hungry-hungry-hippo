# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RorService do
  subject(:organizations) { described_class.call(search:) }

  let(:search) { 'stanford' }

  context 'when the ror service returns results' do
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

    before do
      stub_request(:get, "https://api.ror.org/organizations?query=#{search}")
        .with(headers: { 'Accept' => 'application/json' })
        .to_return(status: 200, body:, headers: { 'Content-Type': 'application/json;charset=UTF-8' })
    end

    it 'returns a successful response' do
      expect(organizations.count).to eq(1)
      expect(organizations.first['name']).to eq('Stanford University')
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
