# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Review work' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }

  let(:manager) { create(:user) }
  let(:reviewer) { create(:user) }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
    allow(Sdr::Repository).to receive(:status)
      .with(druid:).and_return(build(:version_status))

    collection = create(:collection, druid: collection_druid_fixture, managers: [manager], reviewers: [reviewer])
    create(:work, druid:, collection:)
  end

  context 'when the user is not authorized' do
    before do
      sign_in(create(:user))
    end

    it 'redirects to root' do
      put "/works/#{druid}/review"

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the user is a manager' do
    before do
      sign_in(manager)
    end

    it 'returns 400' do
      put "/works/#{druid}/review"

      # Bad request indicates that the user is authorized.
      expect(response).to have_http_status(:bad_request)
    end
  end

  context 'when the user is a reviewer' do
    before do
      sign_in(reviewer)
    end

    it 'returns 400' do
      put "/works/#{druid}/review"

      # Bad request indicates that the user is authorized.
      expect(response).to have_http_status(:bad_request)
    end
  end
end
