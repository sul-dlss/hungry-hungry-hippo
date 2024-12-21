# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Update work' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }

  context 'when the user is not authorized' do
    before do
      create(:work, druid:)
      sign_in(create(:user))
    end

    it 'redirects to root' do
      put "/works/#{druid}"

      expect(response).to redirect_to(root_path)
    end
  end

  # The following tests verify that the user is properly authorized to perform
  # the action. The user must be authorized as either the collection owner,
  # collection manager, or collection depositor to destroy a work in the collection
  #
  # When valid, the return value is an http bad request because we aren't actually
  # sending any parameters to the controller
  context 'when the user is authorized' do
    let(:user) { create(:user) }

    before do
      create(:work, druid:, collection:)
      sign_in(user)
    end

    context 'with the collection owner role' do
      let(:collection) { create(:collection, user:) }

      it 'redirects to root' do
        put "/works/#{druid}"

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with the collection manager role' do
      let(:collection) { create(:collection, managers: [user]) }

      it 'redirects to root' do
        put "/works/#{druid}"

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with the collection depositor role' do
      let(:collection) { create(:collection, depositors: [user]) }

      it 'redirects to root' do
        put "/works/#{druid}"

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
