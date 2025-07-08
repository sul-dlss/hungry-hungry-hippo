# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Change work ownership' do
  include WorkMappingFixtures

  let(:cocina_object) { dro_with_metadata_fixture }
  let(:druid) { cocina_object.externalIdentifier }
  let(:version_status) { build(:openable_version_status) }
  let(:collection) { create(:collection, druid: collection_druid_fixture) }
  let!(:work) { create(:work, druid:, title: title_fixture, collection:, user:) }
  let(:user) { create(:user) }
  let(:new_owner) { create(:user) }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:find_latest_user_version).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    allow(Sdr::Repository).to receive(:open_if_needed) { |args| args[:cocina_object] }
    allow(Sdr::Repository).to receive(:update) do |args|
      @updated_cocina_object = args[:cocina_object]
    end
    allow(Sdr::Repository).to receive(:accession)
    allow(Sdr::Event).to receive(:list).and_return([])
    allow(AccountService).to receive(:call)
      .with(sunetid: new_owner.sunetid)
      .and_return(AccountService::Account.new(
                    name: new_owner.name,
                    sunetid: new_owner.sunetid,
                    description: 'Digital Library Systems and Services'
                  ))
    sign_in(user, groups: ['dlss:hydrus-app-administrators'])
  end

  it 'changes the owner of a work' do
    visit work_path(druid)

    expect(page).to have_css('h1', text: work.title)
    click_link_or_button('Admin functions')
    click_link_or_button('Change ownership')

    fill_in('Enter a valid SUNet ID to change to a new owner', with: new_owner.sunetid)
    find('li.list-group-item', text: 'Click to add').click
    expect(page).to have_field('Enter a valid SUNet ID to change to a new owner',
                               with: "#{new_owner.sunetid}: #{new_owner.name} - Digital Library Systems and Services")
    click_link_or_button('Submit')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_css('.alert', text: "Ownership of the work has been changed to #{new_owner.name}. " \
                                             'The new owner will be notified of the change.')
  end
end
