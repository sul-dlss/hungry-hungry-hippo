# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Articles::Edit::LicenseComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, article_form, vc_test_view_context, {}) }
  let(:article_form) { ArticleForm.new(license:) }
  let(:collection) { instance_double(Collection, required_license_option?: required) }
  let(:license_presenter) { LicensePresenter.new(work_form: article_form, collection:) }

  let(:license) { 'https://creativecommons.org/licenses/by/4.0/legalcode' }

  context 'when the depositor selects the license' do
    let(:required) { false }

    it 'renders the select' do
      render_inline(described_class.new(form:, license_presenter:))

      expect(page).to have_select('license')
      expect(page).to have_css('optgroup[label="Creative Commons"]')
      expect(page).to have_css('option[value="https://creativecommons.org/licenses/by/4.0/legalcode"]',
                               text: 'CC-BY-4.0 Attribution International')
    end
  end

  context 'when the license is required' do
    let(:required) { true }

    it 'states the license and renders a hidden field' do
      render_inline(described_class.new(form:, license_presenter:))

      expect(page).to have_text('The license for this deposit is CC-BY-4.0 Attribution International')
      expect(page).to have_field('license', type: 'hidden', with: 'https://creativecommons.org/licenses/by/4.0/legalcode')
    end
  end
end
