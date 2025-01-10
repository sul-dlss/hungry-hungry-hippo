# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::LicenseComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:work_form) { WorkForm.new(license:) }
  let(:collection) { instance_double(Collection, required_license_option?: required) }
  let(:license_presenter) { LicensePresenter.new(work_form:, collection:) }

  let(:license) { 'https://creativecommons.org/licenses/by/4.0/legalcode' }

  context 'when the depositor selects the license' do
    let(:required) { false }

    it 'renders the select' do
      render_inline(described_class.new(form:, license_presenter:))

      expect(page).to have_select('license')
      expect(page).to have_css('optgroup[label="Creative Commons"]')
      expect(page).to have_css('option[value="https://creativecommons.org/licenses/by/4.0/legalcode"]',
                               text: 'CC-BY-4.0 Attribution International')
      # Does not have deprecated licenses
      expect(page).to have_no_css('option[value="https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode"]')
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

      expect(page).to have_text('The license for this deposit is CC-BY-4.0 Attribution International')
      expect(page).to have_field('license', type: 'hidden', with: 'https://creativecommons.org/licenses/by/4.0/legalcode')
    end
  end
end
