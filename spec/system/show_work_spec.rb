# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show a work', :rack_test do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let(:collection) { create(:collection, user:) }
  let!(:work) { create(:work, druid: druid, title: title_fixture, collection:, user:) }
  let(:cocina_object) { dro_with_structural_and_metadata_fixture }
  let(:version_status) do
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, version: 2,
                                                                         openable?: true, accessioning?: false)
  end

  before do
    allow(Sdr::Repository).to receive(:find).with(druid: druid).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid: druid).and_return(version_status)

    sign_in(user)
  end

  it 'creates a work draft' do
    visit work_path(druid)

    expect(page).to have_css('h1', text: work.title)
    expect(page).to have_css('.status', text: 'Deposited')
    expect(page).to have_link('Edit or deposit', href: edit_work_path(druid))

    # Files table
    within('table#files-table') do
      expect(page).to have_css('caption', text: 'Files')
      expect(page).to have_css('th', text: 'Filename')
      expect(page).to have_css('th', text: 'Description')
      expect(page).to have_css('td', text: filename_fixture)
    end

    # Title table
    within('table#title-table') do
      expect(page).to have_css('caption', text: 'Title')
      expect(page).to have_css('tr', text: 'Title')
      expect(page).to have_css('td', text: work.title)
    end

    # Description table
    within('table#description-table') do
      expect(page).to have_css('caption', text: 'Description')
      expect(page).to have_css('tr', text: 'Abstract')
      expect(page).to have_css('td', text: abstract_fixture)
    end

    # Related Content table
    within('table#related-content-table') do
      expect(page).to have_css('caption', text: 'Related content')
      expect(page).to have_css('tr', text: 'Related links')
      expect(page).to have_css('td', text: related_links_fixture.first['text'])
    end
  end
end
