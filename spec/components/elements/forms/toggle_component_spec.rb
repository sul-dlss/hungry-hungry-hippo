# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::ToggleComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, contributor_form, vc_test_view_context, {}) }
  let(:contributor_form) { ContributorForm.new }
  let(:field_name) { 'role_type' }
  let(:label) { 'Role Type' }
  let(:component) { described_class.new(form:, field_name:, label:) }

  before do
    component.with_left_toggle_option(form:, field_name:, label: 'Type 1', value: 'type1', data: { test: 'test_data' })
    component.with_right_toggle_option(form:, field_name:, label: 'Type 2', value: 'type2',
                                       data: { test: 'more_test_data' })
  end

  it 'creates toggle field with label' do
    render_inline(component)
    expect(page).to have_css('label.form-label:not(.visually-hidden)', text: 'Role Type')
    expect(page).to have_css('input[type="radio"]:not(.is-invalid)')
    expect(page).to have_css('input[data-test="test_data"]')
    expect(page).to have_css('label.btn.rounded-start-pill', text: 'Type 1')
    expect(page).to have_css('label.btn.rounded-end-pill', text: 'Type 2')
    expect(page).to have_no_css('p.form-text')
    expect(page).to have_no_css('div.invalid-feedback.is-invalid')
  end
end
