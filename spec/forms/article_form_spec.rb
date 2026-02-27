# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArticleForm, type: :form do
  let(:form) { described_class.new(identifier:) }

  let(:identifier) { '10.1234/nonexistent' }
  let(:base_error) { 'You will need to use the "Deposit to this collection" button to deposit this work.' }
  let(:not_found_error) { "Unable to retrieve metadata for this DOI/PMID/PMCID. #{base_error}" }
  let(:not_article_error) { "The metadata for this identifier indicates it is not a journal article. #{base_error}" }
  let(:no_title_error) { "The metadata for this identifier does not include a title. #{base_error}" }

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
        expect(form.errors[:identifier]).to include(not_found_error)
      end
    end

    context 'when identifier is present but is not a journal article' do
      before do
        allow(CrossrefService).to receive(:call).with(doi: identifier).and_raise(CrossrefService::NotJournalArticle)
      end

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:identifier]).to include(not_article_error)
      end
    end

    context 'when identifier is present but does not have a title' do
      before do
        allow(CrossrefService).to receive(:call).with(doi: identifier).and_return({ title: nil })
      end

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:identifier]).to include(no_title_error)
      end
    end

    context 'when identifier is a PMID that is not found' do
      let(:identifier) { '12345' }

      before do
        allow(PubmedService).to receive(:call).with(search: identifier).and_raise(PubmedService::NotFound)
      end

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:identifier]).to include(not_found_error)
      end
    end

    context 'when identifier is a PMID that is found and the DOI is then found in CrossRef' do
      let(:identifier) { '56789' }
      let(:doi) { '10.10/some-doi' }

      before do
        allow(PubmedService).to receive(:call).with(search: identifier).and_return(doi)
        allow(CrossrefService).to receive(:call).with(doi:).and_return({ title: 'Sample Title' })
      end

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when identifier is a PMID that is found but the DOI is not found in CrossRef' do
      let(:identifier) { '56789' }
      let(:doi) { '10.10/some-doi' }

      before do
        allow(PubmedService).to receive(:call).with(search: identifier).and_return(doi)
        allow(CrossrefService).to receive(:call).with(doi:).and_raise(CrossrefService::NotFound)
      end

      it 'is valid' do
        expect(form).not_to be_valid
        expect(form.errors[:identifier]).to include(not_found_error)
      end
    end
  end
end
