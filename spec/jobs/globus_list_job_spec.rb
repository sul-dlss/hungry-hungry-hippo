# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GlobusListJob do
  let(:content) { create(:content, :with_content_files, user:) }
  let(:user) { create(:user) }
  let(:path) { "#{user.sunetid}/new" }
  let(:endpoint_client) { instance_double(GlobusClient::Endpoint, disallow_writes: true, list_files: file_infos) }
  let(:file_infos) { [GlobusClient::Endpoint::FileInfo.new(size: 123, name: 'file1.txt')] }

  describe '#perform' do
    before do
      allow(GlobusClient::Endpoint).to receive(:new).and_return(endpoint_client)
      allow(Turbo::StreamsChannel).to receive(:broadcast_action_to)
    end

    it 'creates lists the files in the Globus directory' do
      described_class.perform_now(content:)
      expect(GlobusClient::Endpoint).to have_received(:new)
        .with(user_id: user.email_address, path: "#{user.sunetid}/new", notify_email: false)
      expect(endpoint_client).to have_received(:disallow_writes)
      expect(endpoint_client).to have_received(:list_files)
      expect(Turbo::StreamsChannel).to have_received(:broadcast_action_to).exactly(2).times

      expect(content.reload.content_files.size).to eq 1
      content_file = content.content_files.first
      expect(content_file.file_type).to eq 'globus'
      expect(content_file.size).to eq 123
      expect(content_file.label).to eq ''
      expect(content_file.filepath).to eq 'file1.txt'
    end
  end
end
