# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::RepeatableNestedComponent, type: :component do
  subject(:component) do
    described_class.new(form:, field_name: :related_links, model_class: RelatedLinkForm,
                        form_component: RelatedLinks::EditComponent, hidden_label:, bordered:)
  end

  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:work_form) { WorkForm.new }

  context 'when rendering the default component' do
    let(:hidden_label) { false }
    let(:bordered) { true }

    it 'renders the nested component' do
      render_inline(component)
      expect(page).to have_text('Related links')
      expect(page).to have_field('Link text')
      expect(page).to have_field('URL')
      expect(page).to have_no_css('label.visually-hidden')
      expect(page).to have_css('div.border-3')
      expect(page).to have_no_css('div.align-items-stretch')
    end
  end

  context 'when hiding the label for the component' do
    let(:hidden_label) { true }
    let(:bordered) { true }

    it 'does not render the label' do
      render_inline(component)
      expect(page).to have_css('label.visually-hidden')
    end
  end

  context 'when rendering the component borderless' do
    let(:hidden_label) { true }
    let(:bordered) { false }

    it 'does not include the border classes' do
      render_inline(component)
      expect(page).to have_no_css('div.border-3')
    end
  end

  context 'when a single field' do
    subject(:component) do
      described_class.new(form:, field_name: :contact_emails, model_class: ContactEmailForm,
                          form_component: ContactEmails::EditComponent, hidden_label:, bordered:, single_field:)
    end

    let(:single_field) { true }
    let(:hidden_label) { false }
    let(:bordered) { true }

    it 'aligns the delete icon' do
      render_inline(component)
      expect(page).to have_css('div.align-items-stretch')
    end
  end
end
