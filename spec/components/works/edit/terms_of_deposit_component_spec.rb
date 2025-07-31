# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::TermsOfDepositComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_view_context, {}) }
  let(:work_form) { WorkForm.new(agree_to_terms:) }

  context 'when the user has already agreed to terms of deposit' do
    let(:agree_to_terms) { true }

    it 'includes a hidden field' do
      render_inline(described_class.new(form:))

      expect(page).to have_field('agree_to_terms', type: 'hidden', with: 'true')
    end
  end

  context 'when the user has not yet agreed to terms of deposit' do
    let(:agree_to_terms) { false }

    it 'renders the terms' do
      render_inline(described_class.new(form:))
      expect(page).to have_link('FAQs and download Terms of Deposit', href: Settings.terms_url)
      expect(page).to have_css('turbo-frame[id="terms-of-deposit"][src="/terms"]')
      expect(page).to have_field('agree_to_terms', type: 'checkbox', checked: false)
    end
  end
end
