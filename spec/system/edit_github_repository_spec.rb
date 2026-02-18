# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit a Github repository' do
  # Using mapping fixtures because it provides a roundtrippable DRO.
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let(:cocina_object) do
    dro_with_structural_and_metadata_fixture
  end
  let(:version_status) { build(:openable_version_status, version: cocina_object.version) }
  let(:updated_title) { 'My new title' }

  let(:collection) do
    create(:collection, :with_required_contact_email, user:, druid: collection_druid_fixture)
  end
  let!(:work) { create(:github_repository, druid:, user:, collection:) }

  before do
    # On the second call, this will return the cocina object submitted to update.
    # This will allow us to test the updated values.
    allow(Sdr::Repository).to receive(:find).with(druid:).and_invoke(
      ->(_arg) { cocina_object }, # edit
      ->(_arg) { cocina_object }, # DepositWorkJob
      ->(_arg) { @updated_cocina_object } # show after update
    )
    allow(Sdr::Repository).to receive(:find_latest_user_version).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(
      build(:openable_version_status, version: cocina_object.version),
      build(:draft_version_status, version: cocina_object.version)
    )
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    # It is already open.
    allow(Sdr::Repository).to receive(:open_if_needed) { |args| args[:cocina_object] }
    allow(Sdr::Repository).to receive(:update) do |args|
      @updated_cocina_object = args[:cocina_object]
    end
    allow(Sdr::Event).to receive(:list).and_return([])

    sign_in(user)
  end

  it 'edits a Github repository' do
    visit edit_work_path(druid, tab: 'title')

    expect(page).to have_css('h1', text: title_fixture)

    expect(page).to have_button('Next')
    expect(page).to have_no_button('Save as draft')
    expect(page).to have_no_button('Discard draft')

    fill_in('Title of deposit', with: updated_title)

    find('.nav-link', text: 'Deposit', exact_text: true).click
    expect(page).to have_field('work[whats_changing]', with: 'Metadata update', type: 'hidden')
    expect(page).to have_checked_field('work[github_deposit_enabled]', with: true)
    choose('No')

    click_link_or_button('Save')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: updated_title)
    expect(page).to have_css('.status', text: 'New version in draft')
    expect(page).to have_link('Edit or deposit', href: edit_work_path(druid))

    expect(work.reload.github_deposit_enabled).to be(false)

    # Ahoy event is created
    expect(Ahoy::Event.where_event(Ahoy::Event::WORK_UPDATED, work_id: work.id, deposit: true,
                                                              review: false).count).to eq(1)
  end
end
