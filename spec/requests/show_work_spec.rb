# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show work' do
  include MappingFixtures

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
      get "/works/#{druid}"

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the deposit job started' do
    let!(:work) { create(:work, :deposit_job_started, druid:, user:) }
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    it 'redirects to waiting page' do
      get "/works/#{druid}"

      expect(response).to redirect_to(wait_works_path(work.id))
    end
  end
end
