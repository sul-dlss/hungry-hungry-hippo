# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArticleForm, type: :form do
  let(:form) { described_class.new(doi:) }

  let(:doi) { '10.1234/nonexistent' }

  describe 'DOI validations' do
    context 'when DOI is not present' do
      let(:doi) { nil }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:doi]).to include("can't be blank")
      end
    end

    context 'when DOI is present and found in Crossref' do
      before do
        allow(CrossrefService).to receive(:call).with(doi:).and_return({ title: 'Sample Title' })
      end

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when DOI is present but not found in Crossref' do
      before do
        allow(CrossrefService).to receive(:call).with(doi:).and_raise(CrossrefService::NotFound)
      end

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:doi]).to include('not found')
      end
    end

    context 'when DOI is present but is not a journal article' do
      before do
        allow(CrossrefService).to receive(:call).with(doi:).and_raise(CrossrefService::NotJournalArticle)
      end

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:doi]).to include('is not a journal article')
      end
    end
  end
end
