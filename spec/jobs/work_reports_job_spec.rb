# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkReportsJob, :active_job_test_adapter do
  include ActionMailer::TestHelper

  subject(:job) { described_class.new }

  let(:user) { create(:user) }
  let(:work_report_form) { Admin::WorkReportForm.new }
  let(:csv) { 'csv content' }
  let(:params) do
    {
      current_user: user
    }
  end
  let(:mailer) { instance_double(WorkReportsMailer, work_report_email: delivery_object) }
  let(:delivery_object) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

  describe '#perform' do
    before do
      allow(Admin::WorkReport).to receive(:call).with(work_report_form:).and_return('csv content')
      allow(WorkReportsMailer).to receive(:with).with(csv:, current_user: params[:current_user]).and_return(mailer)
      allow(mailer).to receive(:with).and_return(mailer)
      allow(delivery_object).to receive(:deliver_now)
    end

    it 'calls Admin::WorkReport with the work report form' do
      described_class.perform_now(work_report_form:, current_user: user)
      expect(Admin::WorkReport).to have_received(:call).with(work_report_form:)
    end

    it 'sends an email with the work report CSV' do
      described_class.perform_now(work_report_form:, current_user: user)
      expect(WorkReportsMailer).to have_received(:with).with(current_user: user, csv:)
      expect(mailer).to have_received(:work_report_email)
    end
  end
end
