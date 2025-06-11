# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search for a collection or work by druid' do
  include CollectionMappingFixtures
  include WorkMappingFixtures

  let(:version_status) { build(:version_status) }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    allow(Sdr::Event).to receive(:list).and_return([])

    sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
  end

  context 'when searching for a collection' do
    let(:druid) { collection_druid_fixture }
    let(:cocina_object) { collection_with_metadata_fixture }

    before do
      create(:collection, druid:, title: collection_title_fixture)
    end

    it 'redirects to the collection page' do
      visit admin_dashboard_path

      expect(page).to have_css('h1', text: 'Admin dashboard')

      fill_in 'Search for DRUID', with: druid
      click_link_or_button('Search')

      # Redirect to collection page
      expect(page).to have_css('h1', text: collection_title_fixture)
    end
  end

  context 'when searching for a work' do
    let(:druid) { druid_fixture }
    let(:cocina_object) { dro_with_metadata_fixture }

    before do
      create(:work, druid:, title: title_fixture)
    end

    it 'redirects to the work page' do
      visit admin_dashboard_path

      expect(page).to have_css('h1', text: 'Admin dashboard')

      # Note that this tests a bare druid. The form will add the 'druid:' prefix.
      fill_in 'Search for DRUID', with: druid.delete_prefix('druid:')
      click_link_or_button('Search')

      # Redirect to work page
      expect(page).to have_css('h1', text: title_fixture)
    end
  end
end
