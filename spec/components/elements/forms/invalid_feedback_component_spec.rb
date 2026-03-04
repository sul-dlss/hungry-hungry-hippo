# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::InvalidFeedbackComponent, type: :component do
  let(:component) { described_class.new(field_name: :text, form:) }

  let(:form) { ActionView::Helpers::FormBuilder.new(nil, keyword_form, vc_test_view_context, {}) }

  let(:keyword_form) { KeywordForm.new(text:) }
  let(:text) { 'some keyword' }

  before do
    keyword_form.validate(:deposit)
  end

  context 'when there are no errors' do
    it 'does not render' do
      expect(component.render?).to be false
    end
  end

  context 'when there are errors' do
    let(:text) { nil }

    it 'renders the error message' do
      render_inline(component)
      expect(page).to have_css('div.invalid-feedback.is-invalid.d-block#text_error', text: "can't be blank")
    end
  end

  context 'when excepting certain error types' do
    let(:component) { described_class.new(field_name: :text, form:, except: [:blank]) }
    let(:text) { nil }

    it 'does not render the excepted error messages' do
      expect(component.render?).to be false
    end
  end
end
