# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::CheckboxComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, related_work_form, vc_test_controller.view_context, {}) }
  let(:field_name) { :use_citation }
  let(:related_work_form) { RelatedWorkForm.new(use_citation:) }
  let(:use_citation) { false }

  it 'creates field with label' do
    render_inline(described_class.new(form:, field_name:))
    expect(page).to have_css('label.form-check-label:not(.visually-hidden)', text: field_name)
    expect(page).to have_css('input.form-check-input[type="checkbox"]:not(.is-invalid)')
    expect(page).to have_no_css('p.form-text')
    expect(page).to have_no_css('div.invalid-feedback.is-invalid')
    expect(page.find('input.form-check-input[type="checkbox"]')).not_to be_checked
  end

  context 'when label is hidden' do
    it 'creates field with hidden label' do
      render_inline(described_class.new(form:, field_name:, hidden_label: true))
      expect(page).to have_css('label.form-check-label.visually-hidden', text: field_name)
    end
  end

  context 'when value of field name is true' do
    let(:use_citation) { true }

    it 'renders with the checkbox already checked' do
      render_inline(described_class.new(form:, field_name:))
      expect(page.find('input.form-check-input[type="checkbox"]')).to be_checked
    end
  end

  context 'when help text is provided' do
    it 'creates field with help text' do
      render_inline(described_class.new(form:, field_name:, help_text: 'Helpful text'))
      expect(page).to have_css("input[aria-describedby='#{field_name}_help']")
      expect(page).to have_css("p.form-text[id='#{field_name}_help']", text: 'Helpful text')
    end
  end

  context 'when field has an error' do
    before do
      related_work_form.errors.add(field_name, 'is required')
    end

    it 'creates field with invalid feedback' do
      render_inline(described_class.new(form:, field_name:))

      expect(page).to have_css('.form-check-input.is-invalid')
      expect(page).to have_css('div.invalid-feedback.is-invalid', text: 'is required')
    end
  end

  context 'when data is provided' do
    it 'creates field with data' do
      render_inline(described_class.new(form:, field_name:, data: { test: 'test_data' }))
      expect(page).to have_css('input[data-test="test_data"]')
    end
  end

  context 'when input classes are provided' do
    it 'creates field with classes' do
      render_inline(described_class.new(form:, field_name:, input_classes: 'test-class'))
      expect(page).to have_field(:use_citation, class: 'form-check-input test-class')
    end
  end
end
