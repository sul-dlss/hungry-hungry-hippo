# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Discard a work' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let(:cocina_object) do
    dro_with_structural_and_metadata_fixture
  end
  let(:version_status) { build(:draft_version_status, version: cocina_object.version) }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    allow(Sdr::Repository).to receive(:discard_draft)
    allow(Sdr::Event).to receive(:list).and_return([])

    collection = create(:collection, user:, druid: collection_druid_fixture)
    create(:work, druid:, user:, collection:)

    sign_in(user)
  end

  it 'discards a draft' do
    visit edit_work_path(druid)

    find('.nav-link', text: 'Deposit', exact_text: true).click
    accept_confirm(/Are you sure/) do
      click_on('Discard draft')
    end

    expect(page).to have_current_path(work_path(druid))
    expect(page).to have_css('.alert-success', text: 'Draft discarded.')
    expect(Sdr::Repository).to have_received(:discard_draft).with(druid:)
  end
end
