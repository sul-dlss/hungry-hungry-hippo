# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GlobusSetupJob do
  let(:user) { create(:user) }
  let(:path) { "work-#{work.id}" }
  let(:content) { create(:content, :with_content_files, work:) }
  let(:work) { create(:work) }
  let(:ahoy_visit) { Ahoy::Visit.new }

  describe '#perform' do
    before do
      allow(GlobusClient).to receive(:mkdir)
      allow(GlobusClient).to receive(:allow_writes)
      allow(Turbo::StreamsChannel).to receive(:broadcast_action_to)
    end

    it 'creates a Globus directory for the work' do
      described_class.perform_now(user:, content:, ahoy_visit:)
      expect(GlobusClient).to have_received(:mkdir)
        .with(user_id: user.email_address, path: "work-#{work.id}", notify_email: false)
      expect(GlobusClient).to have_received(:allow_writes)
        .with(user_id: user.email_address, path: "work-#{work.id}", notify_email: false)
      expect(content.reload.content_files).to be_empty
      expect(Turbo::StreamsChannel).to have_received(:broadcast_action_to).once
      expect(Ahoy::Event.where_event(Ahoy::Event::GLOBUS_CREATED,
                                     sunetid: user.sunetid,
                                     work_id: work.id,
                                     version: work.version,
                                     druid: work.druid).count).to eq 1
    end
  end
end
