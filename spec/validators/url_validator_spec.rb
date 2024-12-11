# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UrlValidator do
  let(:record) { KeywordForm.new(text: 'Not validated', uri:) }
  let(:uri) { 'http://id.worldcat.org/fast/832383/' }
  let(:validator) { described_class.new({ attributes: ['stub'] }) }

  before do
    validator.validate_each(record, :uri, uri)
  end

  it 'validates' do
    expect(record.errors).to be_empty
  end

  context 'with a nil' do
    let(:uri) { nil }

    it 'fails to validate' do
      expect(record.errors.full_messages.first).to eq('Uri must be a valid HTTP/S URL')
    end
  end

  context 'with a blank string' do
    let(:uri) { '' }

    it 'fails to validate' do
      expect(record.errors.full_messages.first).to eq('Uri must be a valid HTTP/S URL')
    end
  end

  context 'with a non-URL' do
    let(:uri) { 'foobar' }

    it 'fails to validate' do
      expect(record.errors.full_messages.first).to eq('Uri must be a valid HTTP/S URL')
    end
  end

  context 'with a non-HTTP/S URL' do
    let(:uri) { 'mailto:mjgiarlo@stanford.edu' }

    it 'fails to validate' do
      expect(record.errors.full_messages.first).to eq('Uri must be a valid HTTP/S URL')
    end
  end

  context 'with an https URL' do
    let(:uri) { 'https://stanford.edu' }

    it 'validates' do
      expect(record.errors).to be_empty
    end
  end
end
