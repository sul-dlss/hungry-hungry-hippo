# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show collection works' do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }

  context 'when the user is not authorized' do
    before do
      create(:collection, druid:)
      # allow(Sdr::Repository).to receive(:find).with(druid:).and_return(collection_with_metadata_fixture)
      # allow(Sdr::Repository).to receive(:status)
      #   .with(druid:).and_return(instance_double(VersionStatus))
      sign_in(create(:user))
    end

    it 'redirects to root' do
      get "/collections/#{druid}/works"

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the user is authorized' do
    let(:depositor) { create(:user) }

    before do
      create(:collection, druid:, depositors: [depositor])
      sign_in(depositor)
    end

    it 'shows the collection' do
      get "/collections/#{druid}/works"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<turbo-frame id="collection-works">')
      expect(response.body).to include('No deposits to this collection.')
    end
  end
end
