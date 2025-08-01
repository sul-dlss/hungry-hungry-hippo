# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::SelectFieldComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_view_context, {}) }
  let(:work_form) { WorkForm.new }
  let(:field_name) { 'license' }
  let(:options) { [['License Name', 'https://example.com/license']] }
  let(:prompt) { 'Choose an option...' }
  let(:help_text) { 'About this field' }

  it 'creates field with label' do
    render_inline(described_class.new(form:, field_name:, options:, required: false, label: 'license', prompt:))
    expect(page).to have_css('label.form-label:not(.visually-hidden)', text: 'license')
    expect(page).to have_css('select.form-select:not(.is-invalid)')
    expect(page).to have_no_css('p.form-text')
    expect(page).to have_no_css('div.invalid-feedback.is-invalid')
  end

  context 'when help text is provided' do
    it 'creates field with help text' do
      render_inline(described_class.new(form:, field_name:, options:, help_text:, label: 'license', prompt:))
      expect(page).to have_css('label.form-label:not(.visually-hidden)', text: 'license')
      expect(page).to have_css('select.form-select:not(.is-invalid)')
      expect(page).to have_css('p.form-text')
      expect(page).to have_no_css('div.invalid-feedback.is-invalid')
    end
  end

  context 'when field has an error' do
    before do
      work_form.errors.add(field_name, 'is required')
    end

    it 'creates field with invalid feedback' do
      render_inline(described_class.new(form:, field_name:, options:, required: true, prompt:))

      expect(page).to have_css('.form-select.is-invalid')
      expect(page).to have_css('div.invalid-feedback.is-invalid', text: 'is required')
    end
  end
end
