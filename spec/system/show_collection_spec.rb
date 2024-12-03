# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show a collection' do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }
  let(:user) { create(:user) }
  let(:groups) { ['dlss:hydrus-app-collection-creators'] }
  let!(:collection) { create(:collection, druid: druid, title: collection_title_fixture, user:) }
  # Need multiple files to test pagination
  let(:cocina_object) { collection_with_metadata_fixture }
  let(:version_status) do
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, version: 2,
                                                                         openable?: true, accessioning?: false)
  end

  before do
    allow(Sdr::Repository).to receive(:find).with(druid: druid).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid: druid).and_return(version_status)

    Kaminari.configure do |config|
      config.default_per_page = 2
    end

    sign_in(user, groups:)
  end

  it 'shows a collection' do
    visit collection_path(druid)

    expect(page).to have_css('h1', text: collection.title)
    expect(page).to have_css('.status', text: 'Deposited')
    expect(page).to have_link('Edit or deposit', href: edit_collection_path(druid))

    # Title table
    within('table#title-table') do
      expect(page).to have_css('caption', text: 'Title')
      expect(page).to have_css('tr', text: 'Title')
      expect(page).to have_css('td', text: collection.title)
    end

    # Description table
    within('table#description-table') do
      expect(page).to have_css('caption', text: 'Description')
      expect(page).to have_css('tr', text: 'Description')
      expect(page).to have_css('td', text: collection_description_fixture)
    end

    # Related Content table
    within('table#related-content-table') do
      expect(page).to have_css('caption', text: 'Related content')
      expect(page).to have_css('tr', text: 'Related links')
      expect(page).to have_css('td', text: related_links_fixture.first['text'])
    end
  end
end
