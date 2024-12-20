# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'New work' do
  let(:druid) { druid_fixture }

  context 'when the user is not authorized' do
    before do
      create(:collection, druid: collection_druid_fixture)
      sign_in(create(:user))
    end

    it 'redirects to root' do
      get "/works/new?collection_druid=#{collection_druid_fixture}"

      expect(response).to redirect_to(root_path)
    end
  end

  # The following tests verify that the user is properly authorized to perform
  # the action. The user must be authorized as either the collection owner,
  # collection manager, or collection depositor to destroy a work in the collection
  #
  # When valid, the return value is an http OK
  context 'when the user is authorized' do
    context 'with the administrator role' do
      let(:admin_user) { create(:user) }
      let(:groups) { ['dlss:hydrus-app-administrators'] }

      before do
        create(:collection, druid: collection_druid_fixture)
        sign_in(admin_user, groups:)
      end

      it 'displays the work edit page' do
        get "/works/new?collection_druid=#{collection_druid_fixture}"

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with the depositor role' do
      let(:user) { create(:user) }

      before do
        create(:collection, druid: collection_druid_fixture, depositors: [user])
        sign_in(user)
      end

      it 'displays the work edit page' do
        get "/works/new?collection_druid=#{collection_druid_fixture}"

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with the manager role' do
      let(:user) { create(:user) }

      before do
        create(:collection, druid: collection_druid_fixture, managers: [user])
        sign_in(user)
      end

      it 'displays the work edit page' do
        get "/works/new?collection_druid=#{collection_druid_fixture}"

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
