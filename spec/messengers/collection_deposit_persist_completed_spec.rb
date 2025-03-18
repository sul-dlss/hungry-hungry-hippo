# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Messengers::CollectionDepositPersistCompleted, :active_job_test_adapter do
  include ActionMailer::TestHelper

  context 'when first version' do
    let(:collection) do
      create(:collection, deposit_state_event: 'deposit_persist')
    end

    before do
      collection.deposit_persist_complete!
    end

    it 'sends the first version deposited email' do
      described_class.call(object: collection)

      assert_enqueued_email_with CollectionsMailer.with(collection:), :first_version_created_email
    end
  end

  context 'when not first version' do
    let(:collection) { create(:collection, version: 2, deposit_state_event: 'deposit_persist') }

    before do
      collection.deposit_persist_complete!
    end

    it 'does not send an email' do
      assert_no_enqueued_emails do
        described_class.call(object: collection)
      end
    end
  end

  context 'when a work' do
    let(:work) { create(:work, deposit_state_event: 'deposit_persist') }

    before do
      work.deposit_persist_complete!
    end

    it 'does not send an email' do
      assert_no_enqueued_emails do
        described_class.call(object: work)
      end
    end
  end
end
