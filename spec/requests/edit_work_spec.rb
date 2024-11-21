# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit work' do
  include MappingFixtures

  let(:druid) { druid_fixture }

  context 'when the user is not authorized' do
    before do
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
      allow(Sdr::Repository).to receive(:status)
        .with(druid:).and_return(instance_double(Dor::Services::Client::ObjectVersion::VersionStatus))

      create(:work, druid:)
      sign_in(create(:user))
    end

    it 'redirects to root' do
      get "/works/#{druid}/edit"

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the deposit job started' do
    let!(:work) { create(:work, :deposit_job_started, druid:) }

    before do
      sign_in(create(:user))
    end

    it 'redirects to waiting page' do
      get "/works/#{druid}/edit"

      expect(response).to redirect_to(wait_works_path(work.id))
    end
  end

  context 'when the work is not open or openable' do
    let(:user) { create(:user) }
    let(:work) { create(:work, druid:, user:) }
    let(:cocina_object) { build(:dro_with_metadata, title: work.title, id: druid) }
    let(:version_status) do
      instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, openable?: false,
                                                                           accessioning?: true)
    end

    before do
      allow(Sdr::Repository).to receive(:find).with(druid: work.druid).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid: work.druid).and_return(version_status)
      allow(RoundtripValidator).to receive(:roundtrippable?)

      sign_in(user)
    end

    it 'redirects to the show page' do
      get "/works/#{druid}/edit"

      expect(response).to redirect_to(work_path(druid))

      follow_redirect!
      expect(response.body).to include('This work cannot be edited.')
      expect(RoundtripValidator).not_to have_received(:roundtrippable?)
    end
  end

  context 'when the work is not roundtrippable' do
    let(:user) { create(:user) }
    let(:work) { create(:work, druid:, user:) }
    let(:cocina_object) { build(:dro_with_metadata, title: work.title, id: druid) }
    let(:version_status) do
      instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true, openable?: false,
                                                                           version: cocina_object.version)
    end

    before do
      allow(Sdr::Repository).to receive(:find).with(druid: work.druid).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid: work.druid).and_return(version_status)
      allow(RoundtripValidator).to receive(:roundtrippable?).and_call_original

      sign_in(user)
    end

    it 'redirects to the show page' do
      get "/works/#{druid}/edit"

      expect(response).to redirect_to(work_path(druid))

      follow_redirect!
      expect(response.body).to include('This work cannot be edited.')
      expect(RoundtripValidator).to have_received(:roundtrippable?)
    end
  end
end
