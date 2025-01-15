# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Doi do
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

    before do
      allow(Datacite::Client).to receive(:new).and_return(client)
      allow(client).to receive(:exists?).and_return(true)
    end

    it 'returns true' do
      expect(described_class.assigned?(druid:)).to be(true)
    end
  end
end
