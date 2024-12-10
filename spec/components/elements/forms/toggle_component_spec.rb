# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::ToggleComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, author_form, vc_test_controller.view_context, {}) }
  let(:author_form) { AuthorForm.new }
  let(:field_name) { 'role_type' }
  let(:label) { 'Role Type' }
  let(:options) do
    [{ 'label' => 'Type 1', 'value' => 'type1', 'data' => { test: 'test_data' },
       'label_data' => { action: 'label_test_data1' } },
     { 'label' => 'Type 2', 'value' => 'type2', 'data' => { test: 'more_test_data' },
       'label_data' => { action: 'label_test_data2' } }]
  end

  it 'creates toggle field with label' do
    render_inline(described_class.new(form: form, field_name:, options:, label:))
    expect(page).to have_css('label.form-label:not(.visually-hidden)', text: 'Role Type')
    expect(page).to have_css('input[type="radio"]:not(.is-invalid)')
    expect(page).to have_css('input[data-test="test_data"]')
    expect(page).to have_css('label[data-action="label_test_data1"]')
    expect(page).to have_no_css('small.form-text')
    expect(page).to have_no_css('div.invalid-feedback.is-invalid')
  end
end
