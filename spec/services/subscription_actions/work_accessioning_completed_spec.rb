# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionActions::WorkAccessioningCompleted, :active_job_test_adapter do
  include ActionMailer::TestHelper

  context 'when first version' do
    let(:work) { create(:work) }

    it 'sends the deposited email' do
      described_class.call(object: work)

      assert_enqueued_email_with WorksMailer.with(work:), :deposited_email
    end
  end

  context 'when not first version' do
    let(:work) { create(:work, version: 2) }

    it 'sends the new version deposited email' do
      described_class.call(object: work)

      assert_enqueued_email_with WorksMailer.with(work:), :new_version_deposited_email
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
