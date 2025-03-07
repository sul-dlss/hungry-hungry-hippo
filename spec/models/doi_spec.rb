# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Doi do
  include Dry::Monads[:result]

  let(:druid) { druid_fixture }

  describe '#id' do
    it 'returns the DOI id' do
      expect(described_class.id(druid:)).to eq(doi_fixture)
    end
  end

  describe '#url' do
    it 'returns the DOI url' do
      expect(described_class.url(druid:)).to eq("https://doi.org/#{doi_fixture}")
    end
  end

  describe '#assigned?' do
    let(:client) { instance_double(Datacite::Client) }
    let(:response) { Success(true) }

    before do
      allow(Datacite::Client).to receive(:new).and_return(client)
      allow(client).to receive(:exists?).and_return(response)
      allow(Honeybadger).to receive(:notify)
    end

    context 'when the DOI is assigned' do
      it 'returns true' do
        expect(described_class.assigned?(druid:)).to be(true)
        expect(Honeybadger).not_to have_received(:notify)
      end
    end

    context 'when the DOI is not assigned' do
      let(:response) { Success(false) }

      it 'returns false' do
        expect(described_class.assigned?(druid:)).to be(false)
        expect(Honeybadger).not_to have_received(:notify)
      end
    end

    context 'when an error occurs' do
      let(:response) { Failure('error') }

      it 'returns false' do
        expect(described_class.assigned?(druid:)).to be(false)
        expect(Honeybadger).to have_received(:notify)
      end
    end
  end
end
