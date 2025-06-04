# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GlobusListJob do
  let(:content) { create(:content, :with_content_files, user:, work:) }
  let(:user) { create(:user) }
  let(:work) { nil }
  let(:path) { "#{user.sunetid}/new" }

  describe '#perform' do
    before do
      allow(GlobusClient).to receive_messages(disallow_writes: true, list_files: file_infos)
      allow(Turbo::StreamsChannel).to receive(:broadcast_action_to)
    end

    context 'when a new work' do
      let(:file_infos) do
        [
          double(size: 123, name: "/uploads/#{user.sunetid}/new/file1.txt"),
          double(size: 123, name: "/uploads/#{user.sunetid}/new/.DS_Store")
        ]
      end

      it 'creates ContentFiles for the files in the Globus directory' do
        described_class.perform_now(content:)
        expect(GlobusClient).to have_received(:disallow_writes)
          .with(user_id: user.email_address, path:, notify_email: false)
        expect(GlobusClient).to have_received(:list_files)
          .with(user_id: user.email_address, path:, notify_email: false)
        expect(Turbo::StreamsChannel).to have_received(:broadcast_action_to).exactly(2).times

        expect(content.reload.globus_not_in_progress?).to be true
        expect(content.content_files.size).to eq 1
        content_file = content.content_files.first
        expect(content_file.file_type).to eq 'globus'
        expect(content_file.size).to eq 123
        expect(content_file.label).to eq ''
        expect(content_file.filepath).to eq 'file1.txt'
      end
    end

    context 'when an existing work' do
      let(:work) { create(:work) }
      let(:path) { "work-#{work.id}" }
      let(:file_infos) do
        [
          double(size: 123, name: "/uploads/#{path}/file1.txt"),
          double(size: 123, name: "/uploads/#{path}/.DS_Store")
        ]
      end

      it 'creates ContentFiles for the files in the Globus directory' do
        described_class.perform_now(content:)
        expect(GlobusClient).to have_received(:disallow_writes)
          .with(user_id: user.email_address, path:, notify_email: false)
        expect(GlobusClient).to have_received(:list_files)
          .with(user_id: user.email_address, path:, notify_email: false)
        expect(Turbo::StreamsChannel).to have_received(:broadcast_action_to).exactly(2).times

        expect(content.reload.globus_not_in_progress?).to be true
        expect(content.content_files.size).to eq 1
        content_file = content.content_files.first
        expect(content_file.file_type).to eq 'globus'
        expect(content_file.size).to eq 123
        expect(content_file.label).to eq ''
        expect(content_file.filepath).to eq 'file1.txt'
      end
    end

    context 'when cancelled' do
      let(:file_infos) { [] }
      let(:file_info) { double(size: 123, name: "/uploads/#{user.sunetid}/new/file1.txt") }

      before do
        # This cancels on the first file.
        allow(file_infos).to receive(:each_with_index).and_invoke(
          proc do |&block|
            content.globus_list_cancel!
            block.call(file_info, 0)
          end
        )
      end

      it 'creates ContentFiles for the files in the Globus directory' do
        described_class.perform_now(content:, cancel_check_interval: 1)
        expect(GlobusClient).to have_received(:disallow_writes)
          .with(user_id: user.email_address, path:, notify_email: false)
        expect(GlobusClient).to have_received(:list_files)
          .with(user_id: user.email_address, path:, notify_email: false)
        expect(Turbo::StreamsChannel).to have_received(:broadcast_action_to).exactly(2).times
        expect(content.reload.globus_not_in_progress?).to be true
        expect(content.content_files).to be_empty
      end
    end
  end
end
