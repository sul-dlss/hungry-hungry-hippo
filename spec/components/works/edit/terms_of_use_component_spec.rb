# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::TermsOfUseComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:work_form) { WorkForm.new }

  context 'when the additional terms of use are provided by the collection' do
    let(:collection) do
      instance_double(Collection, provided_custom_rights_statement_option?: true,
                                  provided_custom_rights_statement: custom_rights_statement_fixture)
    end

    it 'renders the terms' do
      render_inline(described_class.new(form:, collection:))

      expect(page).to have_css('label', text: 'Additional terms of use')
      expect(page).to have_css('p', text: custom_rights_statement_fixture)
      expect(page).to have_field('custom_rights_statement', type: 'hidden', with: custom_rights_statement_fixture)
    end
  end

  context 'with provided instructions' do
    let(:collection) do
      instance_double(Collection, provided_custom_rights_statement_option?: false,
                                  custom_rights_statement_instructions: instructions)
    end

    let(:instructions) { 'What terms do you want?' }

    it 'renders the provided instructions and input' do
      render_inline(described_class.new(form:, collection:))

      expect(page).to have_css('label', text: 'Additional terms of use (optional)')
      expect(page).to have_css('.form-text', text: instructions)
      expect(page).to have_field('custom_rights_statement', type: 'textarea')
    end
  end
end
