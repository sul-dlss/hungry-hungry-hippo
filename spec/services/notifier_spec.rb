# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notifier do
  describe 'Publishing an event' do
    include ActiveJob::TestHelper
    let(:collection) do
      create(:collection, :with_druid, title: 'My Stuff', reviewers: [reviewer], managers: [manager],
                                       email_depositors_status_changed: true)
    end
    let(:user) { create(:user) }
    let(:reviewer) { create(:user) }
    let(:manager) { create(:user) }

    before do
      allow(ActiveSupport::Notifications).to receive(:instrument).and_call_original
      allow(Settings.notifications).to receive(:enabled).and_return(true)
    end

    context 'with a subscribed mailer' do
      # This tests end-to-end
      it 'sends an email' do
        collection.depositors << user
        expect(ActiveSupport::Notifications).to have_received(:instrument).with(Notifier::DEPOSITOR_ADDED,
                                                                                collection:, user:)
        message = ActionMailer::Base.deliveries.last
        expect(message.to).to eq([user.email_address])
        expect(message.subject).to eq('Invitation to deposit to the My Stuff collection in the SDR')
      end
    end

    context 'with a subscribed action' do
      let(:work) { create(:work, :with_druid, collection:, user:) }

      before do
        allow(Sdr::Event).to receive(:create)
        allow(Current).to receive(:user).and_return(user)
      end

      it 'sends emails' do
        work.request_review!

        expect(ActiveSupport::Notifications).to have_received(:instrument).with(Notifier::REVIEW_REQUESTED,
                                                                                work:, current_user: user)
        expect(has_message(user: reviewer, subject: 'Item ready for review in the My Stuff collection')).to be true
        expect(has_message(user: manager, subject: 'Item ready for review in the My Stuff collection')).to be true
        expect(Sdr::Event).to have_received(:create).with(druid: work.druid, type: 'h3_review_requested',
                                                          data: { who: user.sunetid })
      end
    end
  end

  def has_message(user:, subject:)
    ActionMailer::Base.deliveries.any? { |m| m.to == [user.email_address] && m.subject == subject }
  end
end
