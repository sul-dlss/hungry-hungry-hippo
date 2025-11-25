# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::RepeatableNestedComponent, type: :component do
  subject(:component) do
    described_class.new(form: ActionView::Helpers::FormBuilder.new(nil, form, vc_test_view_context, {}),
                        field_name:, model_class:, form_component:, hidden_label:, bordered:, single_field:)
  end

  let(:field_name) { :related_works }
  let(:form) { WorkForm.new.prepopulate }
  let(:form_component) { RelatedWorks::EditComponent }
  let(:model_class) { RelatedWorkForm }
  let(:hidden_label) { false }
  let(:bordered) { true }
  let(:single_field) { false }

  context 'when rendering the default component' do
    let(:field_name) { :related_links }
    let(:form) { CollectionForm.new.prepopulate }
    let(:form_component) { RelatedLinks::EditComponent }
    let(:model_class) { RelatedLinkForm }

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
    let(:field_name) { :contact_emails }
    let(:form) { WorkForm.new(contact_emails_attributes: contact_emails_fixture).prepopulate }
    let(:form_component) { Works::Edit::ContactEmailsComponent }
    let(:model_class) { ContactEmailForm }
    let(:single_field) { true }

    it 'aligns the delete icon' do
      render_inline(component)
      expect(page).to have_css('div.align-items-stretch')
    end
  end

  context 'when hiding delete button' do
    let(:field_name) { :contributors }
    let(:form) do
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
                       'collection_required' => true
                     }
                   ]).prepopulate
    end
    let(:form_component) { Edit::ContributorComponent }
    let(:model_class) { ContributorForm }

    it 'does not show the delete button' do
      render_inline(component)
      expect(page).to have_text('Contributor')
      expect(page).to have_no_button('Clear')
    end
  end

  context 'when component provides a delete button label' do
    let(:field_name) { :depositors }
    let(:form) do
      CollectionForm.new(depositors_attributes: [
                           {
                             'sunetid' => 'jstanford',
                             'name' => 'Jane Stanford'
                           }
                         ]).prepopulate
    end
    let(:form_component) { Collections::Edit::ParticipantComponent }
    let(:model_class) { ParticipantForm }

    it 'show the delete button with the label specified by the component' do
      render_inline(component)

      expect(page).to have_css('label', text: 'Depositors')
      expect(page).to have_button('Clear Jane Stanford')
    end
  end
end
