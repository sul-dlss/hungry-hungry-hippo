# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Download content file' do
  let(:content_file) { create(:content_file, content:, mime_type: 'text/plain', hide:) }
  let(:user) { create(:user) }
  let(:work) { create(:work, :with_druid) }
  let(:content) { create(:content, work:, user:) }
  let(:version_status) { build(:version_status) }
  let(:hide) { false }
  let(:druid) { work.druid }

  before do
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    sign_in(:user)
    sign_in(user)
  end

  context 'when the user is not authorized' do
    before do
      sign_in(create(:user))
    end

    it 'redirects to root' do
      get "/content_files/#{content_file.id}/download"

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the user is authorized' do
    context 'when the file is not available for download' do
      it 'returns a bad request' do
        get "/content_files/#{content_file.id}/download"

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when the file is available for download and is not yet accessioned' do
      let(:version_status) { build(:first_draft_version_status) }

      before do
        allow(StagingSupport).to receive(:staging_filepath).and_return('spec/fixtures/files/hippo.txt')
      end

      it 'returns the file from staging' do
        get "/content_files/#{content_file.id}/download"

        expect(response).to have_http_status(:ok)
        expect(response.header['Content-Disposition']).to include('attachment')
        expect(response.header['Content-Type']).to eq('text/plain')
        expect(response.body).to eq(File.read('spec/fixtures/files/hippo.txt'))
      end
    end

    context 'when the file is available for download, is already accessioned and is not hidden' do
      let(:version_status) { build(:openable_version_status) }

      it 'returns the file from the stacks' do
        get "/content_files/#{content_file.id}/download"
        expect(response.location).to eq "#{Settings.stacks.file_url}/#{druid}/#{content_file.filepath}"
      end
    end

    context 'when the file is available for download, is already accessioned and is hidden' do
      let(:version_status) { build(:openable_version_status) }
      let(:hide) { true }

      before do
        allow(Preservation::Client.objects).to receive(:content)
      end

      it 'returns the file from preservation' do
        get "/content_files/#{content_file.id}/download"
        expect(Preservation::Client.objects).to have_received(:content).with(
          druid:,
          filepath: content_file.filepath,
          version: version_status.version,
          on_data: Proc
        )
      end
    end
  end
end
