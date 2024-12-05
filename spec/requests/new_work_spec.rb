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

  context 'when the user is an administrator' do
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
end
