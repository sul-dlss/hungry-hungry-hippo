# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::LabelComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, related_work_form, vc_test_view_context, {}) }
  let(:field_name) { :use_citation }
  let(:related_work_form) { RelatedWorkForm.new }

  context 'when label text or content is not provided' do
    it 'creates label using field name' do
      render_inline(described_class.new(form:, field_name:))
      expect(page).to have_css('label.form-label:not(.visually-hidden)', text: field_name.to_s)
    end
  end

  context 'when label text is provided' do
    it 'creates label using label_text' do
      render_inline(described_class.new(form:, field_name:, label_text: 'my label'))
      expect(page).to have_css('label.form-label:not(.visually-hidden)', text: 'my label')
    end
  end

  context 'when content is provided' do
    it 'creates label using content' do
      render_inline(described_class.new(form:, field_name:).with_content('my label'))
      expect(page).to have_css('label.form-label:not(.visually-hidden)', text: 'my label')
    end
  end

  context 'when label is hidden' do
    it 'creates label with hidden label' do
      render_inline(described_class.new(form:, field_name:, hidden_label: true))
      expect(page).to have_css('label.form-label.visually-hidden', text: field_name.to_s)
    end
  end
end
