# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::LicenseComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:work_form) { WorkForm.new(license:) }

  let(:license) { nil }

  it 'renders the select' do
    render_inline(described_class.new(form:))

    expect(page).to have_select('license')
    expect(page).to have_css('option[value=""]', text: 'Select...')
    expect(page).to have_css('optgroup[label="Creative Commons"]')
    expect(page).to have_css('option[value="https://creativecommons.org/licenses/by/4.0/legalcode"]',
                             text: 'CC-BY-4.0 Attribution International')
    # Does not have deprecated licenses
    expect(page).to have_no_css('option[value="https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode"]')
  end

  context 'when form has a deprecated license' do
    let(:license) { 'https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode' }

    it 'includes the deprecated license' do
      render_inline(described_class.new(form:))

      expect(page).to have_css('option[value="https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode"]',
                               text: 'CC-BY-NC-ND-3.0 Attribution Non Commercial No Derivatives (Unsupported)')
    end
  end
end
