# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard', :rack_test do
  let(:druid) { druid_fixture }
  let!(:work) { create(:work, druid: druid, user:, collection:) }
  let!(:work_without_druid) { create(:work, user:, collection:) }
  let(:collection) { create(:collection, user:) }
  let(:user) { create(:user) }
  let(:version_status) do
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, accessioning?: true,
                                                                         openable?: false)
  end

  before do
    allow(Sdr::Repository).to receive(:status).with(druid: druid).and_return(version_status)
    sign_in(user)
  end

  it 'displays the user name in the header' do
    visit root_path

    expect(page).to have_css('h2', text: "#{user.name} - Dashboard")
    expect(page).to have_css('h3', text: 'Your collections')
    expect(page).to have_css('h4', text: collection.title)

    # Works table
    within("table#table_collection_#{collection.id}") do
      within("tr#table_collection_#{collection.id}_work_#{work.id}") do
        expect(page).to have_css('td', text: work.title)
        expect(page).to have_css('td', text: 'Depositing')
      end
      within("tr#table_collection_#{collection.id}_work_#{work_without_druid.id}") do
        expect(page).to have_css('td', text: work_without_druid.title)
        expect(page).to have_css('td', text: 'Saving')
      end
    end
  end
end
