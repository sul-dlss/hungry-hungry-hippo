# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Poll for new GitHub releases' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let!(:work) { create(:github_repository, druid:, title: title_fixture, user:) }
  let(:cocina_object) do
    dro_with_metadata_fixture
  end
  let(:version_status) { build(:openable_version_status) }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    allow(Sdr::Event).to receive(:list).with(druid:).and_return([])

    allow(PollGithubReleasesJob).to receive(:perform_later)

    sign_in(user)
  end

  it 'starts a poll for new GitHub releases' do
    visit work_path(druid)

    expect(page).to have_css('h1', text: work.title)

    click_link_or_button('Check for new GitHub releases')

    expect(page).to have_current_path(work_path(druid))
    expect(page).to have_css('.alert', text: 'Checking for new releases.')

    expect(PollGithubReleasesJob).to have_received(:perform_later).with(github_repository: work,
                                                                        immediate_deposit: true)
  end
end
