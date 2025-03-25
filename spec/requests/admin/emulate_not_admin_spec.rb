# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Emulate being not an admin' do
  describe 'GET /admin/emulate/new' do
    context 'when the user is not authorized' do
      before do
        sign_in(create(:user))
      end

      it 'redirects to root' do
        get '/admin/emulate/new'

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the user is an admin' do
      before do
        sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
      end

      it 'show admin page' do
        get '/admin/emulate/new'

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /admin/emulate' do
    before do
      create(:user)
    end

    context 'when the user is not authorized' do
      before do
        sign_in(create(:user))
      end

      it 'redirects to root' do
        post '/admin/emulate'

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the user is an admin' do
      before do
        sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
      end

      it 'redirects to dashboard' do
        post '/admin/emulate'

        expect(response).to redirect_to(dashboard_path)
      end
    end
  end
end
