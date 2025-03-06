# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notifier do
  describe 'Publishing an event' do
    include ActiveJob::TestHelper
    let(:collection) { create(:collection, :with_druid, title: 'My Stuff', reviewers: [reviewer], managers: [manager]) }
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

      it 'sends emails' do
        work.request_review!

        expect(ActiveSupport::Notifications).to have_received(:instrument).with(Notifier::REVIEW_REQUESTED,
                                                                                work:)
        expect(has_message(user: reviewer, subject: 'Item ready for review in the My Stuff collection')).to be true
        expect(has_message(user: manager, subject: 'Item ready for review in the My Stuff collection')).to be true
      end
    end
  end

  def has_message(user:, subject:)
    ActionMailer::Base.deliveries.any? { |m| m.to == [user.email_address] && m.subject == subject }
  end
end
