# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search for collection' do
  describe 'GET /admin/collection_search/new' do
    context 'when the user is not authorized' do
      before do
        sign_in(create(:user))
      end

      it 'redirects to root' do
        get '/admin/collection_search/new'

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the user is an admin' do
      before do
        sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
      end

      it 'show search form' do
        get '/admin/collection_search/new'

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /admin/collection_search/search' do
    context 'when the user is not authorized' do
      before do
        sign_in(create(:user))
      end

      it 'redirects to root' do
        get '/admin/collection_search/search?q=coll'

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the user is an admin' do
      before do
        sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
      end

      context 'when no results' do
        it 'show search results' do
          get '/admin/collection_search/search?q=coll'

          expect(response).to have_http_status(:ok)
          expect(response.body).to include('<li class="list-group-item" role="option" aria-disabled="true">No collections found</li>') # rubocop:disable Layout/LineLength
        end
      end

      context 'when results' do
        before do
          create(:collection, druid: collection_druid_fixture, title: collection_title_fixture)
          # No druid
          create(:collection, title: 'Collection without druid')
          # Not a match
          create(:collection, :with_druid, title: 'Not it')
        end

        it 'show search results' do
          get '/admin/collection_search/search?q=coll'

          expect(response).to have_http_status(:ok)
          expect(response.body).not_to include('No collections found')
          expect(response.body).not_to include('Collection without druid')
          expect(response.body).not_to include('Not it')
          expect(response.body).to include('<li class="list-group-item" role="option" data-autocomplete-value="/collections/druid:cc234dd5678">My Collection</li>') # rubocop:disable Layout/LineLength
        end
      end
    end
  end
end
