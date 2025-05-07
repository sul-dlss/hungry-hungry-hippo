# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GlobusSetupJob do
  let(:user) { create(:user) }
  let(:path) { "#{user.sunetid}/new" }
  let(:endpoint_client) { instance_double(GlobusClient::Endpoint, mkdir: true, allow_writes: true) }

  describe '#perform' do
    before do
      allow(GlobusClient::Endpoint).to receive(:new).and_return(endpoint_client)
    end

    it 'creates a Globus directory for the user' do
      described_class.perform_now(user:)
      expect(GlobusClient::Endpoint).to have_received(:new)
        .with(user_id: user.email_address, path: "#{user.sunetid}/new", notify_email: false)
      expect(endpoint_client).to have_received(:mkdir)
      expect(endpoint_client).to have_received(:allow_writes)
    end
  end
end
