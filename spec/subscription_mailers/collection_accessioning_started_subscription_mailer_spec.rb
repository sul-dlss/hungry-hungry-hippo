# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionAccessioningStartedSubscriptionMailer, :active_job_test_adapter do
  include ActionMailer::TestHelper

  context 'when first version' do
    let(:collection) do
      create(:collection, deposit_state: 'deposit_registering_or_updating')
    end

    before do
      collection.accession!
    end

    it 'sends the first version deposited email' do
      described_class.call(object: collection, current_user: create(:user))

      assert_enqueued_email_with CollectionsMailer.with(collection:), :first_version_created_email
    end
  end

  context 'when not first version' do
    let(:collection) { create(:collection, version: 2, deposit_state: 'deposit_registering_or_updating') }

    before do
      collection.accession!
    end

    it 'does not send an email' do
      assert_no_enqueued_emails do
        described_class.call(object: collection, current_user: create(:user))
      end
    end
  end

  context 'when a work' do
    let(:work) { create(:work, deposit_state: 'deposit_registering_or_updating') }

    before do
      work.accession!
    end

    it 'does not send an email' do
      assert_no_enqueued_emails do
        described_class.call(object: work, current_user: create(:user))
      end
    end
  end
end
