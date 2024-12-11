# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Destroy work' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }

  context 'when the user is not authorized' do
    before do
      create(:work, druid:)
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
      allow(Sdr::Repository).to receive(:status)
        .with(druid:).and_return(instance_double(Dor::Services::Client::ObjectVersion::VersionStatus))
      sign_in(create(:user))
    end

    it 'redirects to root' do
      delete "/works/#{druid}"

      expect(response).to redirect_to(root_path)
    end
  end
end
