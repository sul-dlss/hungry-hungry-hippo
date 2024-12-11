# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show dashboard', :rack_test do
  let!(:work) { create(:work, :with_druid, user:, collection:) }
  let!(:work_without_druid) { create(:work, user:, collection:) }
  let!(:draft_work) { create(:work, :with_druid, user:, collection:) }
  let(:collection) { create(:collection, :with_druid, user:) }
  let(:user) { create(:user) }
  let(:version_status) do
    VersionStatus.new(status:
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, accessioning?: true,
                                                                         openable?: false))
  end
  let(:draft_version_status) do
    VersionStatus.new(status:
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true, version: 2))
  end

  before do
    allow(Sdr::Repository).to receive(:status).with(druid: work.druid).and_return(version_status)
    allow(Sdr::Repository).to receive(:status).with(druid: draft_work.druid).and_return(draft_version_status)
    sign_in(user)
  end

  it 'displays the user name in the header' do
    visit root_path

    expect(page).to have_css('h2', text: "#{user.name} - Dashboard")

    # Drafts section
    expect(page).to have_css('h3', text: 'Drafts - please complete')
    within('table#drafts-table') do
      expect(page).to have_css('td', text: draft_work.title)
    end

    # Your collections section
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
      within("tr#table_collection_#{collection.id}_work_#{draft_work.id}") do
        expect(page).to have_css('td', text: draft_work.title)
        expect(page).to have_css('td', text: 'New version in draft')
      end
    end
  end
end
