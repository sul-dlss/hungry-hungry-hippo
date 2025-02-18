# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show user' do
  describe 'GET /admin/users' do
    context 'when the user is not authorized' do
      before do
        sign_in(create(:user))
      end

      it 'redirects to root' do
        get '/admin/users'

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the user is an admin' do
      before do
        sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
      end

      it 'show admin page' do
        get '/admin/users'

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /admin/users/:sunetid' do
    before do
      create(:user, email_address: 'h2o2ver@stanford.edu')
    end

    context 'when the user is not authorized' do
      before do
        sign_in(create(:user))
      end

      it 'redirects to root' do
        get '/admin/users/h2o2ver'

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the user is an admin' do
      before do
        sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
      end

      it 'show admin page' do
        get '/admin/users/h2o2ver'

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
