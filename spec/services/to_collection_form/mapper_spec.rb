# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToCollectionForm::Mapper, type: :mapping do
  subject(:collection_form) { described_class.call(cocina_object: collection_with_metadata_fixture, collection:) }

  let(:collection) do
    create(:collection, druid: collection_druid_fixture,
                        user: manager, managers: [manager], depositors: [depositor],
                        reviewers: [reviewer],
                        email_when_participants_changed:,
                        email_depositors_status_changed:,
                        review_enabled:)
  end
  let(:manager) { create(:user, email_address: 'stepking@stanford.edu') }
  let(:depositor) { create(:user, email_address: 'joehill@stanford.edu') }
  let(:reviewer) { create(:user, email_address: 'rbachman@stanford.edu') }
  let(:review_enabled) { false }
  let(:email_when_participants_changed) { true }
  let(:email_depositors_status_changed) { true }

  it 'maps to collection form' do
    expect(collection_form).to equal_form(collection_form_fixture)
  end

  context 'when review is not enabled' do
    let(:review_enabled) { false }

    it 'maps to collection form' do
      expect(collection_form.review_enabled).to be false
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
