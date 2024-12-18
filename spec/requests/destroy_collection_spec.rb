# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Destroy collection' do
  include CollectionMappingFixtures

  let(:druid) { druid_fixture }

  context 'when the user is not authorized' do
    before do
      create(:collection, druid:)
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(collection_with_metadata_fixture)
      allow(Sdr::Repository).to receive(:status)
        .with(druid:).and_return(instance_double(Dor::Services::Client::ObjectVersion::VersionStatus))
      sign_in(create(:user))
    end

    it 'redirects to root' do
      delete "/collections/#{druid}"

      expect(response).to redirect_to(root_path)
    end
  end
end
