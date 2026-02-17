# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RelatedWorkForm do
  subject(:form) { described_class.new(citation:, identifier:, relationship:, use_citation:) }

  let(:citation) { '' }
  let(:identifier) { 'https://example.org/foo/bar' }
  let(:relationship) { described_class::RELATIONSHIP_TYPES.sample }
  let(:use_citation) { false }

  it { is_expected.to be_valid }

  context 'when identifier and citation are both blank' do
    let(:identifier) { '' }

    it { is_expected.to be_valid }

    context 'when relationship is not in the expected list' do
      let(:relationship) { 'is the best ever compared to' }

      it { is_expected.to be_valid }
    end
  end

  context 'when identifier does not appear to be a URI' do
    let(:identifier) { 'My DOI dot org' }

    it { is_expected.not_to be_valid }

    it 'has the custom error message' do
      form.valid?
      expect(form.errors.messages_for(:identifier)).to contain_exactly('must be a valid URL')
    end
  end

  context 'when relationship is not in the expected list' do
    let(:relationship) { 'is the best ever compared to' }

    it { is_expected.not_to be_valid }
  end

  context 'when citation is present' do
    let(:citation) { citation_fixture }

    it { is_expected.to be_valid }

    context 'when relationship is not in the expected list' do
      let(:relationship) { 'is the best ever compared to' }

      it { is_expected.not_to be_valid }
    end

    context 'when in deposit context' do
      it { is_expected.not_to be_valid(:deposit) }

      context 'with identifier attribute also set' do
        let(:identifier) { 'https://doi.example.edu/10.6666/my-work' }

        it { is_expected.not_to be_valid(:deposit) }
      end
    end
  end

  context 'when in deposit context' do
    it { is_expected.to be_valid(:deposit) }
  end

  describe '#to_s' do
    it 'returns the identifier' do
      expect(form.to_s).to eq(identifier)
    end

    context 'when identifier blank' do
      let(:identifier) { '' }
      let(:citation) { citation_fixture }

      it 'returns the citation' do
        expect(form.to_s).to eq(citation)
      end
    end
  end
end
