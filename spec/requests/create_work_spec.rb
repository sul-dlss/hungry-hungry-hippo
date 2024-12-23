# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create work' do
  include WorkMappingFixtures

  let(:user) { create(:user) }

  context 'when the user is not authorized' do
    before do
      create(:collection, druid: collection_druid_fixture)
      sign_in(create(:user))
    end

    it 'redirects to root' do
      post '/works', params: { work: { collection_druid: collection_druid_fixture } }

      expect(response).to redirect_to(root_path)
    end
  end

  # The following tests verify that the user is properly authorized to perform
  # the action. The user must be authorized as either the collection owner,
  # a collection manager or collection depositor to create a work in the collection
  #
  # This is verified by confirming that the user is able to submit the new work form
  # resulting in a 422 Unprocessable Entity response instead of being redirected to the root path
  context 'when the user is authorized' do
    let(:content) { new_content_fixture }

    context 'with the collection owner role' do
      before do
        create(:collection, druid: collection_druid_fixture, user:)
        sign_in(user)
      end

      it 'is able to submit the new work form' do
        post '/works', params: { work: { collection_druid: collection_druid_fixture, content_id: content.id } }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with the collection manager role' do
      before do
        create(:collection, druid: collection_druid_fixture, managers: [user])
        sign_in(user)
      end

      it 'is able to submit the new work form' do
        post '/works', params: { work: { collection_druid: collection_druid_fixture, content_id: content.id } }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with the collection depositor role' do
      before do
        create(:collection, druid: collection_druid_fixture, depositors: [user])
        sign_in(user)
      end

      it 'is able to submit the new work form' do
        post '/works', params: { work: { collection_druid: collection_druid_fixture, content_id: content.id } }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
