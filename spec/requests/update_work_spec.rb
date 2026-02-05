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

  context 'when the work cannot be deposited' do
    let(:user) { create(:user) }
    let(:work) { create(:work, druid:, collection:, user:, deposit_state: :accessioning) }
    let(:collection) { create(:collection, :with_druid) }
    let(:content) { create(:content, :with_content_files, user:, work:) }
    let(:update_work_params) do
      {
        work: {
          content_id: content.id,
          collection_druid: collection.druid,
          title: 'Fake Title',
          whats_changing: 'Initial version',
          lock: "W/\"#{work.druid}=1=1\""
        }
      }
    end

    before do
      allow(RoundtripSupport).to receive(:changed?).and_return(true)
      allow(DepositWorkJob).to receive(:perform_later)
      allow(Sdr::Repository).to receive(:find).with(druid: work.druid).and_return(dro_with_metadata_fixture)
      allow(Sdr::Repository).to receive(:latest_user_version).and_return(work.version)
      sign_in(user)
    end

    it 'redirects to work show page w/ warning text' do
      put "/works/#{work.druid}", params: update_work_params

      expect(response).to redirect_to(work_path(work))
      follow_redirect!
      expect(response.body).to include(
        'We were not able to deposit your item. It may have already been successfully deposited.'
      )
    end
  end
end
