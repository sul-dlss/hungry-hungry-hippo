# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GlobusSetupJob do
  let(:user) { create(:user) }
  let(:path) { "#{user.sunetid}/new" }
  let(:content) { create(:content, :with_content_files, work:) }
  let(:work) { nil }

  describe '#perform' do
    before do
      allow(GlobusClient).to receive(:mkdir)
      allow(GlobusClient).to receive(:allow_writes)
      allow(Turbo::StreamsChannel).to receive(:broadcast_action_to)
    end

    context 'when a new work' do
      it 'creates a Globus directory for the user' do
        described_class.perform_now(user:, content:)
        expect(GlobusClient).to have_received(:mkdir)
          .with(user_id: user.email_address, path: "#{user.sunetid}/new", notify_email: false)
        expect(GlobusClient).to have_received(:allow_writes)
          .with(user_id: user.email_address, path: "/uploads/#{user.sunetid}/new", notify_email: false)
        expect(content.reload.content_files).to be_empty
        expect(Turbo::StreamsChannel).to have_received(:broadcast_action_to).once
      end
    end

    context 'when an existing work' do
      let(:work) { create(:work) }

      it 'creates a Globus directory for the work' do
        described_class.perform_now(user:, content:)
        expect(GlobusClient).to have_received(:mkdir)
          .with(user_id: user.email_address, path: "work-#{work.id}", notify_email: false)
        expect(GlobusClient).to have_received(:allow_writes)
          .with(user_id: user.email_address, path: "/uploads/work-#{work.id}", notify_email: false)
        expect(content.reload.content_files).to be_empty
        expect(Turbo::StreamsChannel).to have_received(:broadcast_action_to).once
      end
    end
  end
end
