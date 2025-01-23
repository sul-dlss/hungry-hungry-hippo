# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit collection' do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }

  context 'when the user is not authorized' do
    before do
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(collection_with_metadata_fixture)
      allow(Sdr::Repository).to receive(:status)
        .with(druid:).and_return(instance_double(Dor::Services::Client::ObjectVersion::VersionStatus))

      create(:collection, druid:)
      sign_in(create(:user))
    end

    it 'redirects to root' do
      get "/collections/#{druid}/edit"

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the deposit job started' do
    let!(:collection) { create(:collection, :registering_or_updating, druid:) }

    before do
      sign_in(create(:user))
    end

    it 'redirects to waiting page' do
      get "/collections/#{druid}/edit"

      expect(response).to redirect_to(wait_collections_path(collection.id))
    end
  end

  context 'when the collection is not open or openable' do
    let(:user) { create(:user) }
    let(:groups) { ['dlss:hydrus-app-collection-creators'] }
    let(:collection) { create(:collection, druid:, user:) }
    let(:cocina_object) { build(:collection_with_metadata, title: collection.title, id: druid) }
    let(:version_status) do
      VersionStatus.new(status:
      instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, openable?: false,
                                                                           accessioning?: true, discardable?: false,
                                                                           version: 1))
    end

    before do
      allow(Sdr::Repository).to receive(:find).with(druid: collection.druid).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid: collection.druid).and_return(version_status)
      allow(ToCollectionForm::RoundtripValidator).to receive(:roundtrippable?)

      sign_in(user, groups:)
    end

    it 'redirects to the show page' do
      get "/collections/#{druid}/edit"

      expect(response).to redirect_to(collection_path(druid))

      follow_redirect!
      expect(response.body).to include('This collection cannot be edited.')
      expect(ToCollectionForm::RoundtripValidator).not_to have_received(:roundtrippable?)
    end
  end

  context 'when the collection is not roundtrippable' do
    let(:user) { create(:user) }
    let(:groups) { ['dlss:hydrus-app-collection-creators'] }
    let(:collection) { create(:collection, user:, druid:) }
    let!(:cocina_object) { build(:collection_with_metadata, title: collection.title, id: druid) }
    let(:version_status) do
      VersionStatus.new(status:
      instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true, openable?: false,
                                                                           version: cocina_object.version))
    end

    before do
      allow(Sdr::Repository).to receive(:find).with(druid: collection.druid).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid: collection.druid).and_return(version_status)
      allow(ToCollectionForm::RoundtripValidator).to receive(:roundtrippable?).and_call_original

      sign_in(user, groups:)
    end

    it 'redirects to the show page' do
      get "/collections/#{druid}/edit"

      expect(response).to redirect_to(collection_path(druid))

      follow_redirect!
      expect(response.body).to include('This collection cannot be edited.')
      expect(ToCollectionForm::RoundtripValidator).to have_received(:roundtrippable?)
    end
  end
end
