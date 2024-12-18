# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrcidResolver do
  include Dry::Monads[:result]

  subject(:response) { described_class.call(orcid_id:) }

  let(:body) do
    {
      'last-modified-date' => { 'value' => 1_460_763_728_406 },
      'name' => {
        'created-date' => { 'value' => 1_460_763_728_406 },
        'last-modified-date' => { 'value' => 1_460_763_728_406 },
        'given-names' => { 'value' => 'Justin' },
        'family-name' => { 'value' => 'Littman' },
        'credit-name' => nil,
        'source' => nil,
        'visibility' => 'public',
        'path' => '0000-0003-1527-0030'
      },
      'other-names' => {
        'last-modified-date' => nil,
        'other-name' => [],
        'path' => '/0000-0003-1527-0030/other-names'
      },
      'biography' => nil,
      'path' => '/0000-0003-1527-0030/personal-details'
    }.to_json
  end

  context 'when bad orcid id' do
    let(:orcid_id) { 'abcd-efgh-ijkl-mnop' }

    it { is_expected.to eq(Failure(400)) }
  end

  context 'when an orcid id' do
    let(:orcid_id) { '0000-0003-1527-0030' }

    before do
      stub_request(:get, "#{Settings.orcid.public_api_base_url}0000-0003-1527-0030/personal-details")
        .with(
          headers: {
            'Accept' => 'application/json',
            'User-Agent' => 'Stanford Self-Deposit (Happy Heron)'
          }
        )
        .to_return(status: 200, body:, headers: {})
    end

    it { is_expected.to eq(Success(%w[Justin Littman])) }
  end

  context 'when an orcid id that requires normalizing' do
    let(:orcid_id) { 'https://orcid.org/0000-0003-1527-003x' }

    before do
      stub_request(:get, "#{Settings.orcid.public_api_base_url}0000-0003-1527-003X/personal-details")
        .to_return(status: 200, body:, headers: {})
    end

    it { is_expected.to eq(Success(%w[Justin Littman])) }
  end

  context 'when ORCID API returns an error' do
    let(:orcid_id) { 'https://orcid.org/0000-0003-1527-0030' }

    before do
      stub_request(:get, "#{Settings.orcid.public_api_base_url}0000-0003-1527-0030/personal-details")
        .to_return(status: 404, body: '', headers: {})
    end

    it { is_expected.to eq(Failure(404)) }
  end
end
