# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit work' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }

  let(:roundtrip_warning) do
    'If you need to make a change to this work, contact <a href="mailto:sdr-support@lists.stanford.edu">sdr-support@lists.stanford.edu</a>' # rubocop:disable Layout/LineLength
  end

  context 'when the user is not authorized' do
    before do
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
      allow(Sdr::Repository).to receive(:status)
        .with(druid:).and_return(build(:version_status))

      create(:work, druid:, collection: create(:collection, druid: collection_druid_fixture))
      sign_in(create(:user))
    end

    it 'redirects to root' do
      get "/works/#{druid}/edit"

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the user is an administrator' do
    let(:admin_user) { create(:user) }
    let(:groups) { ['dlss:hydrus-app-administrators'] }
    let(:version_status) { build(:openable_version_status) }

    before do
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
      create(:work, druid:, collection: create(:collection, druid: collection_druid_fixture))
      sign_in(admin_user, groups:)
    end

    it 'displays the work edit page' do
      get "/works/#{druid}/edit"

      expect(response).to have_http_status(:ok)
    end
  end

  context 'when the deposit job started' do
    let!(:work) { create(:work, :registering_or_updating, druid:) }

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
    let(:work) { create(:work, druid:, user:, collection: create(:collection, druid: collection_druid_fixture)) }
    let(:cocina_object) do
      build(:dro_with_metadata, title: work.title, id: druid, collection_ids: [collection_druid_fixture])
    end
    let(:version_status) { build(:accessioning_version_status) }

    before do
      allow(Sdr::Repository).to receive(:find).with(druid: work.druid).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid: work.druid).and_return(version_status)
      allow(ToWorkForm::RoundtripValidator).to receive(:roundtrippable?)
    end

    context 'when the user is the depositor' do
      before do
        sign_in(user)
      end

      it 'redirects to the show page' do
        get "/works/#{druid}/edit"

        expect(response).to redirect_to(work_path(druid))

        follow_redirect!
        expect(response.body).to include(roundtrip_warning)
        expect(ToWorkForm::RoundtripValidator).not_to have_received(:roundtrippable?)
      end
    end
  end

  context 'when the work is not roundtrippable' do
    let(:user) { create(:user) }
    let(:collection) { create(:collection, :with_druid, user:) }
    let(:work) { create(:work, druid:, user:, collection:) }
    let(:cocina_object) { build(:dro_with_metadata, title: work.title, id: druid, collection_ids: [collection.druid]) }
    let(:version_status) { build(:draft_version_status, version: cocina_object.version) }

    before do
      allow(Sdr::Repository).to receive(:find).with(druid: work.druid).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid: work.druid).and_return(version_status)
      allow(ToWorkForm::RoundtripValidator).to receive(:roundtrippable?).and_call_original

      sign_in(user)
    end

    it 'redirects to the show page' do
      get "/works/#{druid}/edit"

      expect(response).to redirect_to(work_path(druid))

      follow_redirect!
      expect(response.body).to include(roundtrip_warning)
      expect(ToWorkForm::RoundtripValidator).to have_received(:roundtrippable?)
    end
  end

  context 'when the cocina object does not have a collection' do
    let(:user) { create(:user) }
    let(:work) { create(:work, druid:, user:) }
    let(:cocina_object) do
      build(:dro_with_metadata, title: work.title, id: druid)
    end
    let(:version_status) { build(:first_draft_version_status) }

    before do
      allow(Sdr::Repository).to receive(:find).with(druid: work.druid).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid: work.druid).and_return(version_status)
      allow(ToWorkForm::RoundtripValidator).to receive(:roundtrippable?)

      sign_in(user)
    end

    it 'redirects to the show page' do
      get "/works/#{druid}/edit"

      expect(response).to redirect_to(work_path(druid))

      follow_redirect!
      expect(response.body).to include(roundtrip_warning)
      expect(ToWorkForm::RoundtripValidator).not_to have_received(:roundtrippable?)
    end
  end

  context 'when the collection from the cocina object cannot be found' do
    let(:user) { create(:user) }
    let(:work) { create(:work, druid:, user:) }
    let(:cocina_object) do
      build(:dro_with_metadata, title: work.title, id: druid, collection_ids: ['druid:gj446wf8162'])
    end
    let(:version_status) { build(:first_draft_version_status) }

    before do
      allow(Sdr::Repository).to receive(:find).with(druid: work.druid).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid: work.druid).and_return(version_status)
      allow(ToWorkForm::RoundtripValidator).to receive(:roundtrippable?)

      sign_in(user)
    end

    it 'redirects to the show page' do
      get "/works/#{druid}/edit"

      expect(response).to redirect_to(work_path(druid))

      follow_redirect!
      expect(response.body).to include(roundtrip_warning)
      expect(ToWorkForm::RoundtripValidator).not_to have_received(:roundtrippable?)
    end
  end
end
