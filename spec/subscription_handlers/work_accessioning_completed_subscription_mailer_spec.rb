# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkAccessioningCompletedSubscriptionMailer, :active_job_test_adapter do
  include ActionMailer::TestHelper

  let(:user) { create(:user) }
  let(:deposit_shared_user) { create(:user) }

  context 'when first version' do
    let(:work) { create(:work, user:) }

    before do
      create(:share, user: deposit_shared_user, work:, permission: Share::VIEW_EDIT_DEPOSIT_PERMISSION)
    end

    it 'sends the deposited email' do
      described_class.call(object: work)

      assert_enqueued_email_with WorksMailer.with(work:, user:), :deposited_email
      assert_enqueued_email_with WorksMailer.with(work:, user: deposit_shared_user), :deposited_email
    end
  end

  context 'when not first version' do
    let(:work) { create(:work, version: 2, user:) }

    before do
      create(:share, user: deposit_shared_user, work:, permission: Share::VIEW_EDIT_DEPOSIT_PERMISSION)
    end

    it 'sends the new version deposited email' do
      described_class.call(object: work)

      assert_enqueued_email_with WorksMailer.with(work:, user:), :new_version_deposited_email
      assert_enqueued_email_with WorksMailer.with(work:, user: deposit_shared_user), :new_version_deposited_email
    end
  end

  context 'when a collection' do
    # Creating a collection sends an email. let! ensures it is sent before the assert below.
    let!(:collection) { create(:collection) }

    it 'does not send an email' do
      assert_no_enqueued_emails do
        described_class.call(object: collection)
      end
    end
  end
end
