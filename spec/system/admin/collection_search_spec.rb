# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search for a collection' do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }
  let(:cocina_object) { collection_with_metadata_fixture }
  let(:version_status) { build(:version_status) }

  before do
    create(:collection, druid:, title: collection_title_fixture)
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)

    sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
  end

  it 'redirects to the collection page' do
    visit admin_dashboard_path

    expect(page).to have_css('h1', text: 'Admin dashboard')

    fill_in 'Search for collections', with: 'Not my collection'
    expect(page).to have_text('No collections found')

    fill_in 'Search for collections', with: 'coll'

    find('li', text: collection_title_fixture).click

    # Redirect to collection page
    expect(page).to have_css('h1', text: collection_title_fixture)
  end
end
