# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArticleForm, type: :form do
  let(:form) { described_class.new(identifier:) }

  let(:identifier) { '10.1234/nonexistent' }

  describe 'identifier validations' do
    context 'when identifier is not present' do
      let(:identifier) { nil }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:identifier]).to include("can't be blank")
      end
    end

    context 'when identifier is present and found in Crossref' do
      before do
        allow(CrossrefService).to receive(:call).with(doi: identifier).and_return({ title: 'Sample Title' })
      end

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when identifier has whitespace' do
      let(:form) { described_class.new(identifier: "  #{identifier}  ") }

      before do
        allow(CrossrefService).to receive(:call).with(doi: identifier).and_return({ title: 'Sample Title' })
      end

      it 'trims the whitespace and is valid' do
        expect(form).to be_valid
      end
    end

    context 'when identifier is present but not found in Crossref' do
      before do
        allow(CrossrefService).to receive(:call).with(doi: identifier).and_raise(CrossrefService::NotFound)
      end

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:identifier]).to include('identifier was not found')
      end
    end

    context 'when identifier is present but is not a journal article' do
      before do
        allow(CrossrefService).to receive(:call).with(doi: identifier).and_raise(CrossrefService::NotJournalArticle)
      end

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:identifier]).to include('identifier is not a journal article')
      end
    end

    context 'when identifier is present but does not have a title' do
      before do
        allow(CrossrefService).to receive(:call).with(doi: identifier).and_return({ title: nil })
      end

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:identifier]).to include('identifier does not have a title')
      end
    end

    context 'when identifier is a PMID that is not found' do
      let(:identifier) { '12345' }

      before do
        allow(PubmedService).to receive(:call).with(search: identifier).and_raise(PubmedService::NotFound)
      end

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:identifier]).to include('identifier was not found')
      end
    end
  end
end
