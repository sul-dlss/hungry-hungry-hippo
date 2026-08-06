# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkAccessioningStartedSubscriptionMailer, :active_job_test_adapter do
  include ActionMailer::TestHelper

  let(:current_user) { create(:user) }

  context 'when work' do
    let(:manager) { create(:user) }
    let(:collection) { create(:collection, managers: [manager, current_user]) }
    let(:work) { create(:work, collection:) }

    it 'sends the managers depositing email to each manager other than the current user' do
      described_class.call(object: work, current_user:)

      assert_enqueued_email_with WorksMailer.with(work:, user: manager), :managers_depositing_email
      assert_enqueued_emails 1
    end
  end

  context 'when a collection' do
    # Creating a collection sends an email. let! ensures it is sent before the assert below.
    let!(:collection) { create(:collection) }

    it 'does not send an email' do
      assert_no_enqueued_emails do
        described_class.call(object: collection, current_user:)
      end
    end
  end
end
