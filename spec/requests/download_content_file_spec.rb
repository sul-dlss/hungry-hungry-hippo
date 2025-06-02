# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Download content file' do
  let(:content_file) { create(:content_file, content:, mime_type: 'text/plain') }
  let(:user) { create(:user) }
  let(:work) { create(:work, :with_druid) }
  let(:content) { create(:content, work:, user:) }

  context 'when the user is not authorized' do
    before do
      sign_in(create(:user))
    end

    it 'redirects to root' do
      get "/content_files/#{content_file.id}/download"

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the file is not available for download' do
    before do
      sign_in(user)
    end

    it 'returns a bad request' do
      get "/content_files/#{content_file.id}/download"

      expect(response).to have_http_status(:bad_request)
    end
  end

  context 'when the file is available for download' do
    before do
      allow(StagingSupport).to receive(:staging_filepath).and_return('spec/fixtures/files/hippo.txt')
      sign_in(user)
    end

    it 'returns the file' do
      get "/content_files/#{content_file.id}/download"

      expect(response).to have_http_status(:ok)
      expect(response.header['Content-Disposition']).to include('attachment')
      expect(response.header['Content-Type']).to eq('text/plain')
      expect(response.body).to eq(File.read('spec/fixtures/files/hippo.txt'))
    end
  end
end
