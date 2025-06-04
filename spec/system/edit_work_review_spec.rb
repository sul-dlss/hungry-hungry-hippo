# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Submit a work for review without changes' do
  # Using mapping fixtures because it provides a roundtrippable DRO.
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let(:cocina_object) do
    dro_with_structural_and_metadata_fixture
  end
  let(:version_status) { build(:draft_version_status, version: cocina_object.version) }

  let(:collection) do
    create(:collection, :with_review_workflow, user:, druid: collection_druid_fixture, depositors: [user])
  end

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(RoundtripSupport).to receive(:changed?).and_return(false)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Event).to receive(:list).and_return([])

    create(:work, druid:, user:, collection:)

    sign_in(user)
  end

  it 'edits a work' do
    visit edit_work_path(druid, tab: 'title')

    expect(page).to have_css('.nav-link.active', text: 'Title')
    expect(page).to have_field('Title of deposit', with: title_fixture)

    # Going to deposit tab
    find('.nav-link', text: 'Deposit', exact_text: true).click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Submit for review')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_css('.status', text: 'Pending review')
  end
end
