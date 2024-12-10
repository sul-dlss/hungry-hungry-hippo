# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::SelectMonthFieldComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:work_form) { WorkForm.new }
  let(:field_name) { 'publication_date' }
  let(:help_text) { 'About this field' }

  it 'creates field with label' do
    render_inline(described_class.new(form: form, field_name:, required: false, label: 'Month'))
    expect(page).to have_css('label.form-label:not(.visually-hidden)', text: 'Month')
    expect(page).to have_css('select.form-select:not(.is-invalid)')
    expect(page).to have_css('option[value=""]', text: '')
    expect(page).to have_css('option[value="1"]', text: 'January')
    expect(page.all('option').length).to eq(13)
    expect(page).to have_no_css('small.form-text')
    expect(page).to have_no_css('div.invalid-feedback.is-invalid')
  end

  context 'when help text is provided' do
    it 'creates field with help text' do
      render_inline(described_class.new(form: form, field_name:, help_text:, label: 'Month'))
      expect(page).to have_css('label.form-label:not(.visually-hidden)', text: 'Month')
      expect(page).to have_css('select.form-select:not(.is-invalid)')
      expect(page).to have_css('small.form-text')
      expect(page).to have_no_css('div.invalid-feedback.is-invalid')
    end
  end

  context 'when field has an error' do
    before do
      work_form.errors.add(field_name, 'is required')
    end

    it 'creates field with invalid feedback' do
      render_inline(described_class.new(form:, field_name:, required: true))

      expect(page).to have_css('.form-select.is-invalid')
      expect(page).to have_css('div.invalid-feedback.is-invalid', text: 'is required')
    end
  end
end
