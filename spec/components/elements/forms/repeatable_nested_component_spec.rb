# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::RepeatableNestedComponent, type: :component do
  subject(:component) do
    described_class.new(form:, field_name: :related_links, model_class: RelatedLinkForm,
                        form_component: RelatedLinks::EditComponent, hidden_label:, bordered:)
  end

  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:work_form) { WorkForm.new }
  let(:hidden_label) { false }
  let(:bordered) { true }

  context 'when rendering the default component' do
    it 'renders the nested component' do
      render_inline(component)
      expect(page).to have_text('Related links')
      expect(page).to have_field('Link text')
      expect(page).to have_field('URL')
      expect(page).to have_no_css('label.visually-hidden')
      expect(page).to have_css('div.border-3')
      expect(page).to have_no_css('div.align-items-stretch')
      expect(page).to have_button('Clear')
    end
  end

  context 'when hiding the label for the component' do
    let(:hidden_label) { true }

    it 'does not render the label' do
      render_inline(component)
      expect(page).to have_css('label.visually-hidden')
    end
  end

  context 'when rendering the component borderless' do
    let(:bordered) { false }

    it 'does not include the border classes' do
      render_inline(component)
      expect(page).to have_no_css('div.border-3')
    end
  end

  context 'when a single field' do
    subject(:component) do
      described_class.new(form:, field_name: :contact_emails, model_class: ContactEmailForm,
                          form_component: Works::Edit::ContactEmailsComponent, hidden_label:, bordered:, single_field:)
    end

    let(:single_field) { true }

    it 'aligns the delete icon' do
      render_inline(component)
      expect(page).to have_css('div.align-items-stretch')
    end
  end

  context 'when hiding delete button' do
    subject(:component) do
      described_class.new(form:, field_name: :contributors, model_class: ContributorForm,
                          form_component: Edit::ContributorComponent)
    end

    let(:work_form) do
      WorkForm.new(contributors_attributes: [
                     {
                       'role_type' => 'person',
                       'person_role' => 'author',
                       'organization_role' => nil,
                       'first_name' => 'Jane',
                       'last_name' => 'Stanford',
                       'with_orcid' => true,
                       'orcid' => '0001-0002-0003-0004',
                       'organization_name' => nil,
                       'stanford_degree_granting_institution' => false,
                       'suborganization_name' => nil,
                       'cited' => true,
                       'collection_required' => true
                     }
                   ])
    end

    it 'does not show the delete button' do
      render_inline(component)
      expect(page).to have_text('Contributor')
      expect(page).to have_no_button('Clear')
    end
  end

  context 'when the field is marked required' do
    subject(:component) do
      described_class.new(form:, field_name: :related_links, model_class: RelatedLinkForm,
                          form_component: RelatedLinks::EditComponent, hidden_label:, bordered:, mark_required: true)
    end

    it 'renders the required marker' do
      render_inline(component)
      expect(page).to have_css('span.required-indicator', text: '*')
    end

    it 'renders the field with aria-required' do
      render_inline(component)
      expect(page).to have_css('input[aria-required="true"]')
    end
  end
end
