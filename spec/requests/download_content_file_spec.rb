# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Download content file' do
  let(:content_file) { create(:content_file, content:, mime_type: 'text/plain', hide:) }
  let(:user) { create(:user) }
  let(:work) { create(:work, :with_druid) }
  let(:content) { create(:content, work:, user:) }
  let(:hide) { false }
  let(:druid) { work.druid }

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
    before do
      sign_in(user)
    end

    context 'when the file is not available on the staging path or from preservation' do
      before do
        allow(Preservation::Client.objects).to receive(:content).and_raise(Preservation::Client::NotFoundError)
      end

      it 'returns a bad request' do
        get "/content_files/#{content_file.id}/download"

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when the file is on the staging filesystem' do
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

    context 'when the file is not on the staging filesystem' do
      let(:hide) { true }

      before do
        allow(Preservation::Client.objects).to receive(:content)
      end

      it 'returns the latest file from preservation' do
        get "/content_files/#{content_file.id}/download"
        expect(Preservation::Client.objects).to have_received(:content).with(
          druid:,
          filepath: content_file.filepath,
          on_data: Proc
        )
      end
    end
  end
end
