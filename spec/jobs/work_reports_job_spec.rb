# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkReportsJob, :active_job_test_adapter do
  include ActionMailer::TestHelper

  subject(:job) { described_class.new }

  let(:user) { create(:user, email_address: 'testuser@stanford.edu') }
  let(:work_report_form) { Admin::WorkReportForm.new }
  let(:csv) { 'csv content' }

  describe '#perform' do
    before do
      allow(Admin::WorkReport).to receive(:call).with(work_report_form:).and_return('csv content')
      allow(WorkReportsMailer).to receive(:with).with(current_user: user, csv:).and_return(WorkReportsMailer)
    end

    it 'calls Admin::WorkReport with the work report form' do
      described_class.perform_now(work_report_form:, current_user: user)
      expect(Admin::WorkReport).to have_received(:call).with(work_report_form:)
    end

    it 'sends an email with the work report CSV' do
      described_class.perform_now(work_report_form:, current_user: user)
      expect(WorkReportsMailer).to have_received(:with).with(current_user: user, csv:)
      expect(WorkReportsMailer.work_report_email).to have_received(:deliver_later)
      assert_enqueued_email_with WorkReportsMailer.with(current_user:, csv:), :work_report_email
    end
  end
end
