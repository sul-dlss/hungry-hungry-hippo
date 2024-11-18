# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::TextareaFieldComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:work_form) { WorkForm.new }
  let(:field_name) { 'title' }

  it 'creates field with label' do
    render_inline(described_class.new(form: form, field_name:))
    expect(page).to have_css('label.form-label:not(.visually-hidden)', text: 'title')
    expect(page).to have_css('textarea.form-control')
    expect(page).to have_no_css('small.form-text')
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
      expect(page).to have_css('textarea[aria-describedby="title_help"]')
      expect(page).to have_css('small.form-text[id="title_help"]', text: 'Helpful text')
    end
  end
end
