# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Update collection' do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }

  context 'when the user is not authorized' do
    before do
      create(:collection, druid:)
      sign_in(create(:user))
    end

    it 'redirects to root' do
      put "/collections/#{druid}"

      expect(response).to redirect_to(root_path)
    end
  end

  # The following tests verify that the user is properly authorized to perform
  # the action. The user must be authorized as either the collection owner
  # or collection manager to destroy the collection
  #
  # When valid, the return value is an http bad request because we aren't actually
  # sending any parameters to the controller
  context 'when the user is authorized' do
    let(:user) { create(:user) }

    context 'with the collection owner role' do
      before do
        create(:collection, druid:, user:)
        sign_in(user)
      end

      it 'redirects to root' do
        put "/collections/#{druid}"

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with the collection manager role' do
      before do
        create(:collection, druid:, managers: [user])
        sign_in(user)
      end

      it 'redirects to root' do
        put "/collections/#{druid}"

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with the collection depositor role' do
      before do
        create(:collection, druid:, depositors: [user])
        sign_in(user)
      end

      it 'redirects to root' do
        put "/collections/#{druid}"

        expect(response).to redirect_to(root_path)
      end
    end
  end
end
