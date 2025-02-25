# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RelatedLinkForm do
  let(:form) { described_class.new(url:, text:) }

  let(:url) { 'https://example.com' }
  let(:text) { 'Example' }

  context 'with url and text' do
    it 'is valid' do
      expect(form).to be_valid
    end
  end

  context 'with url only' do
    let(:text) { '' }

    it 'is not valid' do
      expect(form).not_to be_valid

      expect(form.errors[:text]).to eq(['can\'t be blank'])
    end
  end

  context 'with both blank' do
    let(:text) { '' }
    let(:url) { '' }

    it 'is valid' do
      expect(form).to be_valid
    end
  end

  context 'with blank url' do
    let(:url) { '' }

    it 'is not valid' do
      expect(form).not_to be_valid

      expect(form.errors[:url]).to eq(['is not a valid URL'])
    end
  end

  context 'with an invalid url' do
    let(:url) { 'foo' }

    it 'is not valid' do
      expect(form).not_to be_valid

      expect(form.errors[:url]).to eq(['is not a valid URL'])
    end
  end

  context 'with an invalid url and blank text' do
    let(:url) { 'foo' }
    let(:text) { '' }

    it 'is not valid' do
      expect(form).not_to be_valid

      expect(form.errors[:url]).to eq(['is not a valid URL'])
    end
  end
end
