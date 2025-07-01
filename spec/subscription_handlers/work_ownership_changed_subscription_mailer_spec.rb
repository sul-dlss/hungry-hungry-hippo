# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkOwnershipChangedSubscriptionMailer, :active_job_test_adapter do
  include ActionMailer::TestHelper

  let(:current_user) { create(:user) }
  let(:owner) { create(:user) }

  context 'when work' do
    let(:work) { create(:work, user: owner) }

    it 'sends the work ownership changed email to current user and work owner' do
      described_class.call(object: work, current_user:)

      assert_enqueued_email_with WorksMailer.with(work:, user: owner), :ownership_changed_email
      assert_enqueued_email_with WorksMailer.with(work:, user: current_user), :ownership_changed_email
    end
  end
end
