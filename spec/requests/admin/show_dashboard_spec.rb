# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show admin dashboard' do
  context 'when the user is not authorized' do
    before do
      sign_in(create(:user))
    end

    it 'redirects to root' do
      get '/admin/dashboard'

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the user is an admin' do
    before do
      sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
    end

    it 'show dashboard' do
      get '/admin/dashboard'

      expect(response).to have_http_status(:ok)
    end
  end
end
