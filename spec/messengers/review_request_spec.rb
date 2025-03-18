# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Messengers::ReviewRequest, :active_job_test_adapter do
  include ActionMailer::TestHelper

  let(:work) { create(:work, :with_druid, collection:) }
  let(:collection) do
    create(:collection, reviewers: [reviewer, reviewer_and_manager], managers: [manager, reviewer_and_manager])
  end
  let(:reviewer) { create(:user) }
  let(:manager) { create(:user) }
  let(:reviewer_and_manager) { create(:user) }

  it 'sends an email to each reviewer and manager' do
    described_class.call(work:)

    assert_enqueued_email_with ReviewsMailer.with(user: reviewer, work:), :pending_email
    assert_enqueued_email_with ReviewsMailer.with(user: manager, work:), :pending_email
    assert_enqueued_email_with ReviewsMailer.with(user: reviewer_and_manager, work:), :pending_email
  end
end
