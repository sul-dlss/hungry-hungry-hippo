# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Update work' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }

  before do
    allow(Sdr::Repository).to receive(:status).and_return(build(:openable_version_status))
  end

  context 'when the user is not authorized' do
    context 'when just some user' do
      before do
        create(:work, druid:)
        sign_in(create(:user))
      end

      it 'redirects to root' do
        put "/works/#{druid}"

        expect(response).to redirect_to(root_path)
      end
    end

    context 'with the collection depositor role' do
      let(:user) { create(:user) }
      let(:collection) { create(:collection, depositors: [user]) }

      before do
        create(:work, druid:, collection:)
        sign_in(user)
      end

      it 'redirects to root' do
        put "/works/#{druid}"

        expect(response).to redirect_to(root_path)
      end
    end
  end

  # The following tests verify that the user is properly authorized to perform
  # the action. The user must be authorized as either the collection owner,
  # collection manager, or work owner to destroy a work in the collection
  #
  # When valid, the return value is an http bad request because we aren't actually
  # sending any parameters to the controller
  context 'when the user is authorized' do
    let(:user) { create(:user) }
    let!(:work) { create(:work, druid:, collection:) }
    let(:collection) { create(:collection) }

    before do
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

    context 'when the work owner' do
      let!(:work) { create(:work, druid:, collection:, user:) }

      it 'redirects to root' do
        put "/works/#{druid}"

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
