# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Move a work' do
  include WorkMappingFixtures

  let(:cocina_object) { dro_with_metadata_fixture }
  let(:druid) { cocina_object.externalIdentifier }
  let(:version_status) { build(:openable_version_status) }
  let(:collection) { create(:collection, :with_druid) }
  let!(:new_collection) { create(:collection, :with_druid) }
  let!(:work) { create(:work, druid:, title: title_fixture, collection:) }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    allow(Sdr::Repository).to receive(:open_if_needed) { |args| args[:cocina_object] }
    allow(Sdr::Repository).to receive(:update) do |args|
      @updated_cocina_object = args[:cocina_object]
    end
    allow(Sdr::Repository).to receive(:accession)
    allow(Sdr::Event).to receive(:list).and_return([])

    sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
  end

  it 'moves a work to another collection' do
    visit work_path(druid)

    expect(page).to have_css('h1', text: work.title)
    click_link_or_button('Admin functions')
    click_link_or_button('Move to another collection')

    fill_in('Enter DRUID of the collection you want to move this item to', with: 'foo')
    click_link_or_button('Submit')

    expect(page).to have_css('.invalid-feedback', text: 'not found')

    fill_in('Enter DRUID of the collection you want to move this item to',
            with: new_collection.druid.delete_prefix('druid:'))
    click_link_or_button('Submit')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_css('.alert', text: 'Work moved to the new collection.')
  end
end
