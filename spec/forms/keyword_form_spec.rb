# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KeywordForm do
  let(:form) { described_class.new(text:, uri:) }
  let(:text) { 'Biology' }
  let(:uri) { 'http://id.worldcat.org/fast/832383/' }

  it 'is valid' do
    expect(form).to be_valid
  end

  it 'is valid when depositing' do
    expect(form.valid?(deposit: true)).to be true
  end

  context 'with blank text' do
    let(:text) { '' }

    it 'is valid' do
      expect(form).to be_valid
    end

    context 'when depositing' do
      it 'is not valid' do
        expect(form.valid?(deposit: true)).to be false
      end
    end
  end

  context 'with blank URI' do
    let(:uri) { '' }

    it 'is valid' do
      expect(form).to be_valid
    end
  end

  context 'with malformed URI' do
    let(:uri) { 'foobar' }

    it 'is valid' do
      expect(form).to be_valid
    end
  end
end
