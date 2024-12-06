# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::TextFieldComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:work_form) { WorkForm.new }
  let(:field_name) { 'title' }

  it 'creates field with label' do
    render_inline(described_class.new(form: form, field_name:))
    expect(page).to have_css('label.form-label:not(.visually-hidden)', text: 'title')
    expect(page).to have_css('input.form-control[type="text"]:not(.is-invalid)')
    expect(page).to have_no_css('small.form-text')
    expect(page).to have_no_css('div.invalid-feedback.is-invalid')
    expect(page).to have_css('div.field-container', visible: :visible)
  end

  context 'when label is hidden' do
    it 'creates field with hidden label' do
      render_inline(described_class.new(form:, field_name:, hidden_label: true))
      expect(page).to have_css('label.form-label.visually-hidden', text: 'title')
    end
  end

  context 'when help text is provided' do
    it 'creates field with help text' do
      render_inline(described_class.new(form:, field_name:, help_text: 'Helpful text'))
      expect(page).to have_css('input[aria-describedby="title_help"]')
      expect(page).to have_css('small.form-text[id="title_help"]', text: 'Helpful text')
    end
  end

  context 'when disabled is set to true' do
    it 'renders the text field as disabled' do
      render_inline(described_class.new(form:, field_name:, disabled: true))
      expect(page.find('input.form-control[type="text"]')).to be_disabled
    end
  end

  context 'when hidden is set to true' do
    it 'renders the containing div as hidden' do
      render_inline(described_class.new(form:, field_name:, hidden: true))
      expect(page).to have_css('div.field-container', visible: :hidden)
    end
  end

  context 'when field has an error' do
    before do
      work_form.errors.add(field_name, 'is required')
    end

    it 'creates field with invalid feedback' do
      render_inline(described_class.new(form:, field_name:))

      expect(page).to have_css('.form-control.is-invalid')
      expect(page).to have_css('div.invalid-feedback.is-invalid', text: 'is required')
    end
  end

  context 'when data is provided' do
    it 'creates field with data' do
      render_inline(described_class.new(form:, field_name:, data: { test: 'test_data' }))
      expect(page).to have_css('input[data-test="test_data"]')
    end
  end

  context 'when placeholder is provided' do
    it 'creates field with placeholder' do
      render_inline(described_class.new(form:, field_name:, placeholder: 'My placeholder'))
      expect(page).to have_css('input[placeholder="My placeholder"]')
    end
  end
end
