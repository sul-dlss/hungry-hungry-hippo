# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::SubmitComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:work_form) { WorkForm.new }

  it 'renders the submit button' do
    render_inline(described_class.new(form:, label: 'Deposit'))
    expect(page).to have_css('input[value="Deposit"]')
    expect(page).to have_css('input[type=submit]') # rubocop:disable Capybara/SpecificMatcher
  end
end
