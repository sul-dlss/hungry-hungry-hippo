# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'New globus' do
  let(:content) { create(:content, user:, work:) }

  let(:work) { create(:work) }

  let(:user) { create(:user) }

  context 'when the user is not authorized' do
    before do
      sign_in(create(:user))
    end

    it 'redirects to root' do
      post "/contents/#{content.id}/globuses"

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the user is authorized' do
    before do
      allow(GlobusSetupJob).to receive(:perform_later)
      sign_in(user)
    end

    it 'redirects to globus uploading path' do
      post "/contents/#{content.id}/globuses"

      expect(response).to redirect_to("/contents/#{content.id}/globuses/uploading")

      expect(GlobusSetupJob).to have_received(:perform_later).with(user:, content:)
    end
  end
end
