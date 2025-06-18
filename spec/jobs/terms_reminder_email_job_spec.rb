# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermsReminderEmailJob, :active_job_test_adapter do
  include ActionMailer::TestHelper

  subject(:job) { described_class.new }

  let!(:new_user) { create(:user, agreed_to_terms_at: nil) } # has not agreed yet, no email
  let!(:recent_user) { create(:user, agreed_to_terms_at: Time.zone.today - 1.day) } # agreed recently, no email
  let!(:old_user_1_year_ago) { create(:user, agreed_to_terms_at: Time.zone.today - 366.days) } # agreed over a year ago
  let!(:old_user_2_years_ago) { create(:user, agreed_to_terms_at: Time.zone.today - 2.years) } # agreed over a year ago

  let(:mailer) { instance_double(TermsMailer, reminder_email: delivery_object) }
  let(:delivery_object) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

  describe '#perform' do
    before do
      allow(TermsMailer).to receive(:with).with(user: User).and_return(mailer)
      allow(mailer).to receive(:with).and_return(mailer)
      allow(delivery_object).to receive(:deliver_now)
    end

    it 'sends an email to just the users who agreed to terms over a year ago' do
      described_class.perform_now
      expect(TermsMailer).to have_received(:with).with(user: old_user_1_year_ago)
      expect(TermsMailer).to have_received(:with).with(user: old_user_2_years_ago)
      expect(TermsMailer).not_to have_received(:with).with(user: new_user)
      expect(TermsMailer).not_to have_received(:with).with(user: recent_user)
      expect(mailer).to have_received(:reminder_email).twice
    end
  end
end
