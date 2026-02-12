# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts search' do
  describe 'GET /accounts/search/:id' do
    let(:user) { create(:user) }

    before do
      allow(AccountService).to receive(:call)
        .with(id: 'jc')
        .and_return(AccountService::Account.new(
                      name: 'Justin Coyne', sunetid: 'jc',
                      description: 'Digital Library Systems and Services'
                    ))
    end

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
      before do
        sign_in user, groups: ['dlss:hydrus-app-collection-creators']
      end

      it 'displays the data' do
        get '/accounts/search?id=jc'
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq({ sunetid: 'jc', name: 'Justin Coyne',
                                             description: 'Digital Library Systems and Services' }
                                             .with_indifferent_access)
      end
    end

    context 'with an authenticated collection manager' do
      before do
        create(:collection, managers: [user])
        sign_in user, groups: []
      end

      it 'displays the data' do
        get '/accounts/search?id=jc'
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when no match' do
      before do
        allow(AccountService).to receive(:call).with(id: 'not_user').and_return(nil)

        sign_in user, groups: ['dlss:hydrus-app-collection-creators']
      end

      it 'displays no results' do
        get '/accounts/search?id=not_user'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
