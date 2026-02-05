# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::CollectionMapper, type: :mapping do
  subject(:collection_form) { described_class.call(cocina_object: collection_with_metadata_fixture, collection:) }

  let(:collection) do
    create(:collection, druid: collection_druid_fixture,
                        user: manager, managers: [manager], depositors: [depositor],
                        reviewers: [reviewer],
                        email_when_participants_changed:,
                        email_depositors_status_changed:,
                        review_enabled:,
                        article_deposit_enabled:,
                        github_deposit_enabled:,
                        work_type: work_type_fixture,
                        work_subtypes: work_subtypes_fixture,
                        works_contact_email: works_contact_email_fixture,
                        contributors:)
  end
  let(:manager) { create(:user, email_address: 'stepking@stanford.edu', name: 'Stephen King') }
  let(:depositor) { create(:user, email_address: 'joehill@stanford.edu', name: 'Joseph Hill') }
  let(:reviewer) { create(:user, email_address: 'rbachman@stanford.edu', name: 'Richard Bachman') }
  let(:review_enabled) { false }
  let(:article_deposit_enabled) { false }
  let(:github_deposit_enabled) { false }
  let(:email_when_participants_changed) { true }
  let(:email_depositors_status_changed) { true }
  let(:contributors) do
    [
      create(:person_contributor,
             :with_affiliation,
             first_name: 'Jane',
             last_name: 'Stanford',
             orcid: '0001-0002-0003-0004'),
      create(:organization_contributor, organization_name: 'Stanford University Libraries', role: 'host_institution'),
      create(:organization_contributor, :stanford)
    ]
  end

  it 'maps to collection form' do
    expect(collection_form).to equal_form(collection_form_fixture)
  end

  context 'when review is enabled' do
    let(:review_enabled) { true }

    it 'maps to collection form' do
      expect(collection_form.review_enabled).to be true
    end
  end

  context 'when article deposit is enabled' do
    let(:article_deposit_enabled) { true }

    it 'maps to collection form' do
      expect(collection_form.article_deposit_enabled).to be true
    end
  end

  context 'when github deposit is enabled' do
    let(:github_deposit_enabled) { true }

    it 'maps to collection form' do
      expect(collection_form.github_deposit_enabled).to be true
    end
  end

  context 'when email_when_participants_changed is false' do
    let(:email_when_participants_changed) { false }

    it 'maps to collection form' do
      expect(collection_form.email_when_participants_changed).to be false
    end
  end

  context 'when email_depositors_status_changed is false' do
    let(:email_depositors_status_changed) { false }

    it 'maps to collection form' do
      expect(collection_form.email_depositors_status_changed).to be false
    end
  end
end
