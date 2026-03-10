# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArticleForm, type: :form do
  let(:form) { described_class.new(identifier:) }

  let(:identifier) { '10.1234/nonexistent' }

  let(:not_found_error) { %r{Unable to retrieve metadata for this DOI/PMCID.} }
  let(:not_article_error) { /The metadata for this identifier indicates it is not a journal article./ }
  let(:incomplete_metadata_error) { /The metadata for this identifier is incomplete./ }

  let(:work_attrs) do
    { title: 'Sample Title', contributors_attributes: [{ first_name: 'A.', last_name: 'User' }] }
  end

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
        allow(CrossrefService).to receive(:call).with(doi: identifier).and_return(work_attrs)
      end

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when identifier has whitespace' do
      let(:form) { described_class.new(identifier: "  #{identifier}  ") }

      before do
        allow(CrossrefService).to receive(:call).with(doi: identifier).and_return(work_attrs)
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
        allow(CrossrefService).to receive(:call)
          .with(doi: identifier)
          .and_return({ title: nil, contributors_attributes: [{ first_name: 'A.', last_name: 'User' }] })
      end

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:identifier]).to include(incomplete_metadata_error)
      end
    end

    context 'when identifier is present but does not have contributors' do
      before do
        allow(CrossrefService).to receive(:call)
          .with(doi: identifier)
          .and_return({ title: 'Sample Title', contributors_attributes: [] })
      end

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:identifier]).to include(incomplete_metadata_error)
      end
    end

    context 'when identifier is a PMCID that is not found' do
      let(:identifier) { '12345' }

      before do
        allow(PubmedService).to receive(:call).with(search: identifier).and_raise(PubmedService::NotFound)
      end

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:identifier]).to include(not_found_error)
      end
    end

    context 'when identifier is a PMCID that is found and the DOI is then found in CrossRef' do
      let(:identifier) { '56789' }
      let(:doi) { '10.10/some-doi' }

      before do
        allow(PubmedService).to receive(:call).with(search: identifier).and_return(doi)
        allow(CrossrefService).to receive(:call).with(doi:).and_return(work_attrs)
      end

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when identifier is a PMCID that is found but the DOI is not found in CrossRef' do
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

  describe 'default license' do
    it 'has the correct default license' do
      expect(form.license).to eq(described_class::DEFAULT_LICENSE)
    end
  end
end
