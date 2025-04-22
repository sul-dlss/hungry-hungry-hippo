# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PurlSupport do
  describe '.purl?' do
    context 'when the URL is a PURL' do
      let(:url) { "#{Settings.purl.url}/abc123" }

      it 'returns true' do
        expect(described_class.purl?(url:)).to be true
      end
    end

    context 'when the URL is not a PURL' do
      let(:url) { 'https://example.com/abc123' }

      it 'returns false' do
        expect(described_class.purl?(url:)).to be false
      end
    end

    context 'when the URL is nil' do
      let(:url) { nil }

      it 'returns false' do
        expect(described_class.purl?(url:)).to be false
      end
    end
  end

  describe '.normalize_https' do
    context 'when the URL starts with http' do
      let(:url) { 'http://example.com/abc123' }

      it 'normalizes to https' do
        expect(described_class.normalize_https(url:)).to eq 'https://example.com/abc123'
      end
    end

    context 'when the URL starts with https' do
      let(:url) { 'https://example.com/abc123' }

      it 'returns the URL unchanged' do
        expect(described_class.normalize_https(url:)).to eq url
      end
    end

    context 'when the URL is nil' do
      let(:url) { nil }

      it 'returns nil' do
        expect(described_class.normalize_https(url:)).to be_nil
      end
    end
  end
end
