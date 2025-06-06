# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Generate an item report' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:cocina_object) { dro_with_metadata_fixture }
  let(:version_status) { build(:version_status) }
  let(:object_client) { instance_double(Dor::Services::Client::Object, find: cocina_object) }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
    sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
    create(:work, druid:)
  end

  context 'when generating a report with no filters' do
    it 'redirects to the work page' do
      visit admin_dashboard_path

      expect(page).to have_css('h1', text: 'Admin dashboard')
      click_link_or_button('Admin functions')
      click_link_or_button('Generate item report')

      # Do not select any filters
      click_link_or_button('Submit')

      # Redirect to item report page
      expect(page).to have_css('div.alert', text: 'Item report requested and will be emailed when completed.')
    end
  end

  context 'when generating a report with filters' do
    it 'redirects to the work page' do
      visit admin_dashboard_path

      expect(page).to have_css('h1', text: 'Admin dashboard')
      click_link_or_button('Admin functions')
      click_link_or_button('Generate item report')

      # Make selections
      check 'Deposited'
      click_link_or_button('Submit')

      # Redirect to item report page
      expect(page).to have_css('div.alert', text: 'Item report requested and will be emailed when completed.')
    end
  end
end
