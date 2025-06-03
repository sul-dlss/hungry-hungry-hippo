# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Uploading globus' do
  let(:content) { create(:content, user:, work:) }

  let(:user) { create(:user) }
  let(:work) { create(:work) }

  context 'when the user is not authorized' do
    before do
      sign_in(create(:user))
    end

    it 'redirects to root' do
      get "/contents/#{content.id}/globuses/uploading"

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the user is authorized' do
    before do
      sign_in(user)
    end

    context 'when a new work' do
      let(:work) { nil }

      it 'renders' do
        get "/contents/#{content.id}/globuses/uploading"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('<turbo-frame id="globus"')
        expect(response.body).to include('Globus file transfer complete')
        expect(response.body).to include("destination_path=/uploads/#{user.sunetid}/new")
      end
    end

    context 'when an existing work' do
      it 'renders' do
        get "/contents/#{content.id}/globuses/uploading"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('<turbo-frame id="globus"')
        expect(response.body).to include('Globus file transfer complete')
        expect(response.body).to include("destination_path=/uploads/work-#{work.id}")
      end
    end
  end
end
