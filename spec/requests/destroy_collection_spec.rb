# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Destroy collection' do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }
  let(:cocina_object) { collection_with_metadata_fixture }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:discard_draft)
  end

  context 'when the user is not authorized' do
    before do
      create(:collection, druid:)
      # allow(Sdr::Repository).to receive(:find).with(druid:).and_return(collection_with_metadata_fixture)
      allow(Sdr::Repository).to receive(:status)
        .with(druid:).and_return(instance_double(Dor::Services::Client::ObjectVersion::VersionStatus))
      sign_in(create(:user))
    end

    it 'redirects to root' do
      delete "/collections/#{druid}"

      expect(response).to redirect_to(root_path)
    end
  end

  # The following tests verify that the user is properly authorized to perform
  # the action. The user must be authorized as either the collection owner
  # or collection manager to destroy the collection
  #
  # When valid, the return value is an http found
  context 'when the user is authorized' do
    let(:collection_owner) { create(:user) }
    let(:collection_manager) { create(:user) }

    before do
      create(:collection,
             druid: collection_druid_fixture,
             user: collection_owner,
             managers: [collection_manager])
      allow(Sdr::Repository).to receive(:status)
        .with(druid:).and_return(
          instance_double(Dor::Services::Client::ObjectVersion::VersionStatus,
                          discardable?: true,
                          version: 1)
        )
    end

    context 'with the collection owner role' do
      before do
        sign_in(collection_owner)
      end

      it 'discards the draft and responds with found' do
        delete "/collections/#{druid}"

        expect(response).to have_http_status(:found)
      end
    end

    context 'with collection manager role' do
      before do
        sign_in(collection_manager)
      end

      it 'discards the draft and responds with found' do
        delete "/collections/#{druid}"

        expect(response).to have_http_status(:found)
      end
    end
  end
end
