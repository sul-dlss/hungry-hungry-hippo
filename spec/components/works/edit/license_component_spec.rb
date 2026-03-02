# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::LicenseComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_view_context, {}) }
  let(:work_form) { WorkForm.new(license:) }
  let(:collection) { instance_double(Collection, required_license_option?: required) }
  let(:license_presenter) { LicensePresenter.new(work_form:, collection:) }

  let(:license) { 'https://creativecommons.org/licenses/by/4.0/legalcode' }
  let(:required) { false }

  context 'when the depositor selects the license' do
    it 'renders the select' do
      render_inline(described_class.new(form:, license_presenter:))

      expect(page).to have_link('Get help selecting a license', href: Settings.license_url)
      expect(page).to have_select('license')
      expect(page).to have_css('optgroup[label="Creative Commons"]')
      expect(page).to have_css('option[value="https://creativecommons.org/licenses/by/4.0/legalcode"]',
                               text: 'CC-BY-4.0 Attribution International')
      # Does not have deprecated licenses
      expect(page).to have_no_css('option[value="https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode"]')

      # shows terms of use
      expect(page).to have_text('In addition to the license, the following Terms of Use')
      expect(page).to have_text('User agrees that, where applicable, content will not be used')
    end

    context 'when form has a deprecated license' do
      let(:license) { 'https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode' }

      it 'includes the deprecated license' do
        render_inline(described_class.new(form:, license_presenter:))

        expect(page).to have_css('option[value="https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode"]',
                                 text: 'CC-BY-NC-ND-3.0 Attribution Non Commercial No Derivatives (Unsupported)')
      end
    end
  end

  context 'when the license is required' do
    let(:required) { true }

    it 'states the license and renders a hidden field' do
      render_inline(described_class.new(form:, license_presenter:))

      expect(page).to have_no_link('Get help selecting a license')

      expect(page).to have_text('The license for this deposit is CC-BY-4.0 Attribution International')
      expect(page).to have_field('license', type: 'hidden', with: 'https://creativecommons.org/licenses/by/4.0/legalcode')
    end
  end

  context 'when terms of use is hidden' do
    it 'does not render terms of use text' do
      render_inline(described_class.new(form:, license_presenter:, show_terms_of_use: false))

      expect(page).to have_no_text('In addition to the license, the following Terms of Use')
      expect(page).to have_no_text('User agrees that, where applicable, content will not be used')
    end
  end

  context 'when license_url is set to a different value' do
    it 'shows a different url' do
      render_inline(described_class.new(form:, license_presenter:, license_help_url: Settings.article_license_url))

      expect(page).to have_link('Get help selecting a license', href: Settings.article_license_url)
    end
  end
end
