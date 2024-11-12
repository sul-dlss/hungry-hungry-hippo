# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::TextFieldComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:work_form) { WorkForm.new }
  let(:field_name) { 'title' }

  it 'creates field with label' do
    render_inline(described_class.new(form: form, field_name:))
    expect(page).to have_css('label')
    expect(page).to have_css('.form-label')
    expect(page).to have_no_css('.visually-hidden')
  end

  it 'creates field with hidden label' do
    render_inline(described_class.new(form:, field_name:, hidden_label: true))
    expect(page).to have_css('label.form-label.visually-hidden')
  end
end
