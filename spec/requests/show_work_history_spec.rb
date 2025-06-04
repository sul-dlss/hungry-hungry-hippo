# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show work' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }

  let(:events) do
    [Dor::Services::Client::Events::Event.new(event_type: 'version_close', timestamp: '2020-01-27T19:10:27.291Z',
                                              data: { 'who' => 'lstanfordjr', 'description' => 'Version 1 closed' })]
  end

  context 'when the user is not authorized' do
    before do
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
    end

    context 'when just some user' do
      before do
        create(:work, druid:)

        sign_in(create(:user))
      end

      it 'redirects to root' do
        get "/works/#{druid}/history"

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the user is a collection depositor' do
      let(:user) { create(:user) }
      let(:collection) { create(:collection, depositors: [user]) }

      before do
        create(:work, druid:, collection:)

        sign_in(user)
      end

      it 'redirects to root' do
        get "/works/#{druid}/history"

        expect(response).to redirect_to(root_path)
      end
    end
  end

  context 'when the user is an administrator' do
    let(:admin_user) { create(:user) }
    let(:groups) { ['dlss:hydrus-app-administrators'] }

    before do
      create(:work, druid:)
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
      allow(Sdr::Event).to receive(:list).with(druid:).and_return(events)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(build(:openable_version_status))

      sign_in(admin_user, groups:)
    end

    it 'renders the history table' do
      get "/works/#{druid}/history"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('History')
    end
  end

  context 'when the user is work owner' do
    let(:user) { create(:user) }

    before do
      create(:work, druid:, user:)
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
      allow(Sdr::Event).to receive(:list).with(druid:).and_return(events)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(build(:openable_version_status))

      sign_in(user)
    end

    it 'renders the history table' do
      get "/works/#{druid}/history"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('History')
    end
  end

  context 'when there are no events' do
    let(:user) { create(:user) }

    let(:events) { [] }

    before do
      create(:work, druid:, user:)
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
      allow(Sdr::Event).to receive(:list).with(druid:).and_return(events)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(build(:openable_version_status))

      sign_in(user)
    end

    it 'does not render the history table' do
      get "/works/#{druid}/history"

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('History')
    end
  end
end
