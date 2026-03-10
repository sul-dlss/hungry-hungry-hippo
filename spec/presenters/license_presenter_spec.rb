# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LicensePresenter do
  let(:presenter) { described_class.new(work_form:, collection:) }
  let(:collection_license_required) { create(:collection, license_option: 'required') }
  let(:collection_license_selectable) { create(:collection, license_option: 'depositor_selects') }

  describe '#required_license_option?' do
    context 'when work_form is an ArticleForm' do
      let(:work_form) { ArticleForm.new }

      context 'when license is required' do
        let(:collection) { collection_license_required }

        it 'returns false because user must always select a license for an article' do
          expect(presenter.required_license_option?).to be false
        end
      end

      context 'when license is selectable' do
        let(:collection) { collection_license_selectable }

        it 'returns false' do
          expect(presenter.required_license_option?).to be false
        end
      end
    end

    context 'when work_form is not an ArticleForm' do
      let(:work_form) { WorkForm.new }

      context 'when license is required' do
        let(:collection) { collection_license_required }

        it 'returns true because license follows collection settings for a work' do
          expect(presenter.required_license_option?).to be true
        end
      end

      context 'when license is selectable' do
        let(:collection) { collection_license_selectable }

        it 'returns false' do
          expect(presenter.required_license_option?).to be false
        end
      end
    end
  end
end
