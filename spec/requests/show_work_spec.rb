# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show work' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }

  context 'when the user is not authorized' do
    before do
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(build(:version_status))
      allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    end

    context 'when just some user' do
      before do
        create(:work, druid:)
        sign_in(create(:user))
      end

      it 'redirects to root' do
        get "/works/#{druid}"

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
        get "/works/#{druid}"

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
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(build(:openable_version_status))
      allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)

      sign_in(admin_user, groups:)
    end

    it 'renders the work show page with admin functions' do
      get "/works/#{druid}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Admin functions')
    end
  end

  context 'when the deposit job started' do
    let!(:work) { create(:work, :registering_or_updating, druid:, user:) }
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    it 'redirects to waiting page' do
      get "/works/#{druid}"

      expect(response).to redirect_to(wait_works_path(work.id))
    end
  end

  context 'when the title and collection have changed' do
    let(:collection) { create(:collection) }
    let!(:new_collection) { create(:collection, druid: collection_druid_fixture) }
    let!(:work) { create(:work, druid:, user:, collection:) }
    let(:user) { create(:user) }

    before do
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(build(:version_status))
      allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)

      sign_in(user)
    end

    it 'syncs the work' do
      expect(work.title).not_to eq(title_fixture)
      expect(work.collection).not_to eq(new_collection)

      get "/works/#{druid}"

      expect(response).to have_http_status(:ok)
      expect(work.reload.title).to eq(title_fixture)
      expect(work.collection).to eq(new_collection)
    end
  end

  context 'when the cocina does not have collection ids' do
    let(:collection) { create(:collection, :with_druid) }
    let!(:work) { create(:work, druid:, user:, collection:) }
    let(:user) { create(:user) }
    let(:cocina_object) { build(:dro_with_metadata, title: title_fixture, id: druid) }

    before do
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(build(:version_status))
      allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)

      sign_in(user)
    end

    it 'renders the work show page' do
      get "/works/#{druid}"

      expect(response).to have_http_status(:ok)
      expect(work.reload.title).to eq(title_fixture)
      expect(work.collection).to eq(collection)
    end
  end

  context 'when the DOI option is turned on' do
    let(:collection) { create(:collection, :with_druid) }
    let!(:work) { create(:work, druid:, user:, collection:, doi_assigned: false) }
    let(:user) { create(:user) }

    before do
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(build(:first_draft_version_status))
      allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)

      allow(Doi).to receive(:assigned?).and_return(false)

      sign_in(user)
    end

    it 'renders the work show page with correct DOI verbiage' do
      get "/works/#{druid}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('https://doi.org/10.80343/bc123df4567')
      expect(response.body).not_to include('https://doi.org/10.80343/bc123df4567</a>')
    end
  end

  context 'when rendering the page' do
    before do
      user = create(:user)
      collection = create(:collection, :with_druid, depositors: [user], title: 'My collection')
      create(:work, druid:, user:, collection:, title: 'My work')
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(build(:openable_version_status))
      allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)

      sign_in(user)
    end

    it 'sets the title' do
      get "/works/#{druid}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<title>SDR | Dashboard | My collection | My title</title>')
    end
  end
end
