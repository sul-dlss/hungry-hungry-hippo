# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show work' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }

  context 'when the user is not authorized' do
    before do
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
      allow(Sdr::Repository).to receive(:status)
        .with(druid:).and_return(instance_double(Dor::Services::Client::ObjectVersion::VersionStatus))
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
      allow(Sdr::Repository).to receive(:status)
        .with(druid:).and_return(
          VersionStatus.new(status:
          instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true, version: 1,
                                                                               openable?: false))
        )

      sign_in(admin_user, groups:)
    end

    it 'display the work show page' do
      get "/works/#{druid}"

      expect(response).to have_http_status(:ok)
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

  context 'when the title and collection have changed' do
    let(:collection) { create(:collection) }
    let!(:new_collection) { create(:collection, druid: collection_druid_fixture) }
    let!(:work) { create(:work, druid:, user:, collection:) }
    let(:user) { create(:user) }

    before do
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
      allow(Sdr::Repository).to receive(:status)
        .with(druid:).and_return(
          VersionStatus.new(status:
          instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true, version: 1,
                                                                               openable?: false))
        )

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
      allow(Sdr::Repository).to receive(:status)
        .with(druid:).and_return(
          VersionStatus.new(status:
          instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true,
                                                                               version: 1, openable?: false))
        )

      sign_in(user)
    end

    it 'thats OK' do
      get "/works/#{druid}"

      expect(response).to have_http_status(:ok)
      expect(work.reload.title).to eq(title_fixture)
      expect(work.collection).to eq(collection)
    end
  end
end
