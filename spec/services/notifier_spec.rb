# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notifier do
  describe 'Publishing an event' do
    include ActiveJob::TestHelper
    let(:collection) { create(:collection, title: 'My Stuff') }
    let(:user) { create(:user) }

    before do
      allow(ActiveSupport::Notifications).to receive(:instrument).and_call_original
    end

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
end
