# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Wait globus' do
  let(:content) { create(:content, user:) }

  let(:user) { create(:user) }

  context 'when the user is not authorized' do
    before do
      sign_in(create(:user))
    end

    it 'redirects to root' do
      get "/contents/#{content.id}/globuses/wait"

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the user is authorized' do
    before do
      sign_in(user)
    end

    it 'renders' do
      get "/contents/#{content.id}/globuses/wait"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<turbo-frame id="globus"')
      expect(response.body).to include('Transferring your files from Globus')
    end
  end
end
