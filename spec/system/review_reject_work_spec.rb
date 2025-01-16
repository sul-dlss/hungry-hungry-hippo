# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Review and reject a work' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let(:collection) { create(:collection, druid: collection_druid_fixture, reviewers: [user], review_enabled: true) }
  let!(:work) { create(:work, druid:, title: title_fixture, collection:, review_state: 'pending_review') }
  let(:cocina_object) { dro_with_metadata_fixture }
  let(:version_status) do
    VersionStatus.new(
      status: instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true, version: 2,
                                                                                   openable?: false,
                                                                                   accessioning?: false,
                                                                                   discardable?: false)
    )
  end

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)

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
    fill_in('Reason for returning', with: "I don't like the cut of your jib.")
    click_on('Submit')

    # On show page
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_css('.status', text: 'Returned')
    expect(page).to have_no_text('Review all details below then approve or reject this deposit.')
  end
end
