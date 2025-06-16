# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionReportsJob, :active_job_test_adapter do
  include ActionMailer::TestHelper

  subject(:job) { described_class.new }

  let(:user) { create(:user) }
  let(:collection_report_form) { Admin::CollectionReportForm.new }
  let(:csv) { 'csv content' }
  let(:params) do
    {
      current_user: user
    }
  end
  let(:mailer) { instance_double(CollectionReportsMailer, collection_report_email: delivery_object) }
  let(:delivery_object) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

  describe '#perform' do
    before do
      allow(Admin::CollectionReport).to receive(:call).with(collection_report_form:).and_return('csv content')
      allow(CollectionReportsMailer).to receive(:with).with(csv:,
                                                            current_user: params[:current_user]).and_return(mailer)
      allow(mailer).to receive(:with).and_return(mailer)
      allow(delivery_object).to receive(:deliver_now)
    end

    it 'calls Admin::CollectionReport with the collection report form' do
      described_class.perform_now(collection_report_form:, current_user: user)
      expect(Admin::CollectionReport).to have_received(:call).with(collection_report_form:)
    end

    it 'sends an email with the collection report CSV' do
      described_class.perform_now(collection_report_form:, current_user: user)
      expect(CollectionReportsMailer).to have_received(:with).with(current_user: user, csv:)
      expect(mailer).to have_received(:collection_report_email)
    end
  end
end
