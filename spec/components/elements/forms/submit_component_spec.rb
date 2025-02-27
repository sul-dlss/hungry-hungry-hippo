# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::SubmitComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:work_form) { WorkForm.new }

  context 'with a label' do
    it 'renders the submit button' do
      render_inline(described_class.new(form:, label: 'Deposit'))
      expect(page).to have_css('button[type=submit][name="commit"][value="Deposit"]', text: 'Deposit')
    end
  end

  context 'with content and a value' do
    it 'renders the submit button' do
      render_inline(described_class.new(form:, value: 'deposit-value').with_content('Deposit'))
      expect(page).to have_css('button[type=submit][name="commit"][value="deposit-value"]', text: 'Deposit')
    end
  end
end
