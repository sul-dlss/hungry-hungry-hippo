# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show collection' do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }

  context 'when the user is not authorized' do
    before do
      create(:collection, druid:)
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(collection_with_metadata_fixture)
      allow(Sdr::Repository).to receive(:status)
        .with(druid:).and_return(instance_double(VersionStatus))
      sign_in(create(:user))
    end

    it 'redirects to root' do
      get "/collections/#{druid}"

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the user is a collection depositor' do
    let(:depositor) { create(:user) }
    let(:cocina_object) { collection_with_metadata_fixture }

    before do
      create(:collection, druid:, depositors: [depositor])
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(build(:version_status))
      sign_in(depositor)
    end

    it 'shows the collection' do
      get "/collections/#{druid}"

      expect(response).to have_http_status(:ok)
    end
  end

  context 'when the deposit job started' do
    let!(:collection) { create(:collection, :registering_or_updating, druid:, user:) }
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    it 'redirects to waiting page' do
      get "/collections/#{druid}"

      expect(response).to redirect_to(wait_collections_path(collection.id))
    end
  end

  context 'when the cocina object has changed' do
    let!(:collection) { create(:collection, druid:, user:) }
    let(:cocina_object) { collection_with_metadata_fixture }
    let(:user) { create(:user) }

    before do
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(build(:version_status))

      sign_in(user, groups: ['dlss:hydrus-app-administrators'])
    end

    it 'updates the collection' do
      get "/collections/#{druid}"

      expect(response).to have_http_status(:ok)
      expect(collection.reload.title).to eq(collection_title_fixture)
      expect(collection.object_updated_at).to eq(cocina_object.modified)
    end
  end
end
