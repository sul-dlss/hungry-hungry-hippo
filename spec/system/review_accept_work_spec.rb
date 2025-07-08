# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Review and accept a work' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let(:collection) { create(:collection, druid: collection_druid_fixture, reviewers: [user], review_enabled: true) }
  let!(:work) { create(:work, druid:, title: title_fixture, collection:, review_state: 'pending_review') }
  let(:cocina_object) { dro_with_metadata_fixture }
  let(:version_status) { build(:draft_version_status) }
  let(:deposit_version_status) { build(:accessioning_version_status) }

  before do
    # Stubbing out for Deposit Job
    allow(Sdr::Repository).to receive(:open_if_needed) { |args| args[:cocina_object] }
    allow(Sdr::Repository).to receive(:update) { |args| args[:cocina_object] }
    allow(Sdr::Repository).to receive(:accession)

    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:find_latest_user_version).and_return(cocina_object)

    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status, deposit_version_status)
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)

    allow(Settings.notifications).to receive(:enabled).and_return(true)
    allow(Sdr::Event).to receive(:create)
    allow(Sdr::Event).to receive(:list).and_return([])

    sign_in(user)
  end

  it 'reviews a work' do
    visit work_path(druid)

    expect(page).to have_css('h1', text: work.title)
    expect(page).to have_css('.status', text: 'Pending review')
    expect(page).to have_text('Review all details below then approve this deposit or return with comments.')

    expect(page).to have_checked_field('Approve')

    # Submit invalid (reason is required)
    choose('Return with comments')
    click_on('Submit')

    expect(page).to have_css('.invalid-feedback', text: "can't be blank")

    # Approve and submit
    choose('Approve')
    click_on('Submit')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_css('.status', text: 'Depositing')
    expect(page).to have_no_text('Review all details below then approve or reject this deposit.')

    expect(Sdr::Event).to have_received(:create).with(druid:, type: 'h3_review_approved', data: { who: user.sunetid })
  end
end
