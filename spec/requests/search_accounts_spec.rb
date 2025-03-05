# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts search' do
  describe 'GET /accounts/search/:id' do
    let(:user) { create(:user) }

    context 'with an authenticated user who is not in any application workgroups' do
      before do
        sign_in user, groups: ['sdr:baz']
      end

      it 'is unauthorized' do
        get '/accounts/search?id=fred'
        expect(response).to redirect_to(:root)
      end
    end

    context 'with an authenticated collection creator' do
      let(:user) { create(:user, name: 'Justin Coyne', email_address: 'jc@stanford.edu') }

      before do
        sign_in user, groups: ['dlss:hydrus-app-collection-creators']
      end

      it 'displays the data' do
        get "/accounts/search?id=#{user.sunetid}"
        expect(response).to have_http_status(:ok)
        expect(response.body).to match <<~HTML.rstrip
            <li class="list-group-item" role="option" data-autocomplete-value="jc" data-autocomplete-label="jc">
              <div class="fw-bold">Justin Coyne (jc)</div>
              <p>Digital Library Systems and Services</p>
              <p class="text-muted">Click to add</p>
          </li>
        HTML
      end
    end

    context 'with an authenticated collection manager' do
      before do
        create(:collection, managers: [user])
        sign_in user, groups: []
      end

      it 'displays the data' do
        get "/accounts/search?id=#{user.sunetid}"
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when no match' do
      before do
        sign_in user, groups: ['dlss:hydrus-app-collection-creators']
      end

      it 'displays no results' do
        get '/accounts/search?id=not_user'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include 'No results for "not_user"'
      end
    end
  end
end
