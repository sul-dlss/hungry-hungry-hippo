# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Articles::Edit::TermsOfDepositComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, article_form, vc_test_view_context, {}) }
  let(:article_form) { ArticleForm.new(agree_to_terms:) }

  context 'when the user has not agreed to the terms' do
    let(:agree_to_terms) { false }

    it 'renders the checkbox' do
      render_inline(described_class.new(form:))

      expect(page).to have_field('I agree to the Terms of Deposit', type: 'checkbox')
    end
  end

  context 'when the user has agreed to the terms' do
    let(:agree_to_terms) { true }

    it 'renders acceptance notice' do
      render_inline(described_class.new(form:))

      expect(page).to have_text('You have accepted the Terms of Deposit')
      expect(page).to have_field('agree_to_terms', type: 'hidden', with: 'true')
    end
  end
end
