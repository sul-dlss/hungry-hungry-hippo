# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search for depositor IDs' do
  let!(:druids) { (works + collections).pluck(:druid).join(' ') }
  let(:works) { create_list(:work, 2, :with_druid) }
  let(:collections) { create_list(:collection, 2, :with_druid) }

  describe 'GET /admin/depositors_search/new' do
    context 'when the user is not authorized' do
      before do
        sign_in(create(:user))
      end

      it 'redirects to root' do
        get '/admin/depositors_search/new'

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the user is authorized' do
      before do
        sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
      end

      it 'shows depositors search page' do
        get '/admin/depositors_search/new'

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /admin/depositors_search/search' do
    context 'when the user is not authorized' do
      before do
        sign_in(create(:user))
      end

      it 'redirects to root' do
        get "/admin/depositors_search/search?admin_depositors_search[druids]=#{URI.encode_uri_component(druids)}"
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the user is authorized' do
      before do
        sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
      end

      it 'shows depositors search page' do
        get "/admin/depositors_search/search?admin_depositors_search[druids]=#{URI.encode_uri_component(druids)}"
        expect(response).to have_http_status(:ok)
      end

      context 'when form is valid' do
        it 'displays work druids alongside SUNet IDs of depositors' do
          get "/admin/depositors_search/search?admin_depositors_search[druids]=#{URI.encode_uri_component(druids)}"
          expect(response).to have_http_status(:ok)
          works.each do |work|
            expect(response.body).to include(work.druid)
            expect(response.body).to include(work.user.sunetid)
          end
          collections.each do |collection|
            expect(response.body).to include(collection.druid)
            expect(response.body).to include(collection.user.sunetid)
          end
        end
      end

      context 'when form is not valid' do
        let!(:druids) { "#{works.pluck(:druid).join(' ')} foobar" }

        it 're-renders the form with errors' do
          get "/admin/depositors_search/search?admin_depositors_search[druids]=#{URI.encode_uri_component(druids)}"
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to match(/druid:foobar not found in Works or Collections/)
        end
      end
    end
  end
end
