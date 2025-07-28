# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionForm do
  include CollectionMappingFixtures

  describe 'custom rights statement validations' do
    let(:form_hash) do
      {
        title: collection_title_fixture,
        description: collection_description_fixture,
        release_option: 'depositor_selects',
        release_duration: 'one_year',
        access: 'depositor_selects',
        license_option: 'required',
        license: collection_license_fixture,
        doi_option: 'yes',
        contact_emails_attributes: contact_emails_fixture,
        related_links_attributes: related_links_fixture,
        managers_attributes: collection_manager_fixture,
        depositors_attributes: collection_depositor_fixture
      }
    end
    let(:form) { described_class.new(form_hash) }

    it 'defaults to no custom rights statement' do
      expect(form.custom_rights_statement_option).to eq 'no'
    end

    context 'when custom rights statement is set to provided' do
      before { form_hash[:custom_rights_statement_option] = 'provided' }

      it 'validates presence of the provided custom rights statement' do
        expect(form.valid?(:deposit)).to be false
        expect(form.errors[:provided_custom_rights_statement]).to include("can't be blank")
      end
    end

    context 'when provided custom rights statement includes line breaks' do
      before do
        form_hash[:custom_rights_statement_option] = 'provided'
        form_hash[:provided_custom_rights_statement] = "This is a test\n\nwith a line break"
      end

      it 'normalizes the line breaks' do
        form.validate
        expect(form.provided_custom_rights_statement).to eq "This is a test\r\n\r\nwith a line break"
      end
    end

    context 'when custom rights statement is set to depositor selects' do
      before { form_hash[:custom_rights_statement_option] = 'depositor_selects' }

      it 'validates presence of the custom rights statement instructions' do
        expect(form.valid?(:deposit)).to be false
        expect(form.errors[:custom_rights_statement_instructions]).to include("can't be blank")
      end
    end

    context 'with no managers' do
      before do
        form_hash[:managers_attributes] = [{}]
      end

      it 'validates presence of at least one manager' do
        expect(form).not_to be_valid
        expect(form.errors[:managers_attributes]).to include('must have at least one manager')
      end
    end

    context 'with review enabled and no reviewers' do
      before do
        form_hash[:review_enabled] = true
        form_hash[:reviewers_attributes] = [{}]
      end

      it 'validates presence of at least one reviewer' do
        expect(form).not_to be_valid
        expect(form.errors[:reviewers_attributes]).to include('must have at least one reviewer')
      end
    end
  end
end
