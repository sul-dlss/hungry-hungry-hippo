# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermsReminderEmailJob, :active_job_test_adapter do
  include ActionMailer::TestHelper

  subject(:job) { described_class.new }

  let(:yesterday) { Time.zone.today - 1.day }
  let(:just_over_one_year_ago) { Time.zone.today - 366.days }
  let(:two_years_ago) { Time.zone.today - 2.years }

  # has not agreed yet, do not send email
  let!(:new_user) { create(:user, agreed_to_terms_at: nil, terms_reminder_email_last_sent_at: nil) }
  # agreed recently, do not send email
  let!(:recent_user) { create(:user, agreed_to_terms_at: yesterday, terms_reminder_email_last_sent_at: nil) }

  # agreed over a year ago, never received reminder email, should get email
  let!(:old_user_1_year_ago) do
    create(:user, agreed_to_terms_at: just_over_one_year_ago, terms_reminder_email_last_sent_at: nil)
  end
  # agreed two years ago, never received reminder email, should get email
  let!(:old_user_2_years_ago) do
    create(:user, agreed_to_terms_at: two_years_ago, terms_reminder_email_last_sent_at: nil)
  end

  # agreed over one year ago, received reminder email less one year ago, do not send email
  let!(:old_user_1_year_ago_not_ready_for_email) do
    create(:user, agreed_to_terms_at: just_over_one_year_ago, terms_reminder_email_last_sent_at: yesterday)
  end

  # agreed two years ago, received reminder email over one year ago, should get email
  let!(:old_user_2_years_ago_ready_for_email) do
    create(:user, agreed_to_terms_at: two_years_ago, terms_reminder_email_last_sent_at: just_over_one_year_ago)
  end

  let(:mailer) { instance_double(TermsMailer, reminder_email: delivery_object) }
  let(:delivery_object) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

  let(:users_to_receive_email) { [old_user_1_year_ago, old_user_2_years_ago, old_user_2_years_ago_ready_for_email] }
  let(:users_to_not_receive_email) { [new_user, recent_user, old_user_1_year_ago_not_ready_for_email] }

  describe '#perform' do
    before do
      allow(TermsMailer).to receive(:with).with(user: User).and_return(mailer)
      allow(mailer).to receive(:with).and_return(mailer)
      allow(delivery_object).to receive(:deliver_now)
    end

    it 'sends email to users who agreed to terms over a year ago and have not received an email since then' do
      described_class.perform_now

      # three user should get emails
      expect(TermsMailer).to have_received(:with).with(user: old_user_1_year_ago)
      expect(TermsMailer).to have_received(:with).with(user: old_user_2_years_ago)
      expect(TermsMailer).to have_received(:with).with(user: old_user_2_years_ago_ready_for_email)

      # three users should should NOT get emails
      expect(TermsMailer).not_to have_received(:with).with(user: new_user)
      expect(TermsMailer).not_to have_received(:with).with(user: recent_user)
      expect(TermsMailer).not_to have_received(:with).with(user: old_user_1_year_ago_not_ready_for_email)

      # exactly three emails went out
      expect(mailer).to have_received(:reminder_email).exactly(3).times # three emails should go out

      # we have recorded the date that the users received the email
      users_to_receive_email.each do |user|
        expect(user.reload.terms_reminder_email_last_sent_at.to_date).to eq(Date.current)
      end

      # users who have not received an email have not been updated
      users_to_not_receive_email.each do |user|
        expect(user.reload.terms_reminder_email_last_sent_at).not_to eq(Date.current)
      end
    end
  end
end
