# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkOwnershipChangedSubscriptionMailer, :active_job_test_adapter do
  include ActionMailer::TestHelper

  let(:current_user) { create(:user) }

  context 'when work' do
    let(:work) { create(:work) }

    it 'sends the work ownership changed email' do
      described_class.call(object: work, current_user:)

      assert_enqueued_email_with WorksMailer.with(work:, current_user:), :ownership_changed_email
    end
  end
end
