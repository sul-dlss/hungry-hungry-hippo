# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search for druid' do
  describe 'GET /admin/druid_search/new' do
    context 'when the user is not authorized' do
      before do
        sign_in(create(:user))
      end

      it 'redirects to root' do
        get '/admin/druid_search/new'

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the user is an admin' do
      before do
        sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
      end

      it 'shows search form' do
        get '/admin/druid_search/new'

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /admin/druid_search/search' do
    context 'when the user is not authorized' do
      before do
        sign_in(create(:user))
      end

      it 'redirects to root' do
        get '/admin/druid_search/search?admin_druid_search[druid]=foo&commit=Submit'

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the user is an admin and no results' do
      before do
        sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
      end

      it 'show search results' do
        get '/admin/druid_search/search?admin_druid_search[druid]=foo&commit=Submit'

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('not found')
      end
    end
  end
end
