# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit a collection' do
  # Using mapping fixtures because it provides a roundtrippable DRO.
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }
  let(:user) { create(:user) }
  let(:groups) { ['dlss:hydrus-app-collection-creators'] }

  let(:cocina_object) do
    collection_with_metadata_fixture
  end

  let(:version_status) do
    VersionStatus.new(status:
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true, openable?: false,
                                                                         version: cocina_object.version,
                                                                         discardable?: false))
  end

  let(:updated_title) { 'My new title' }
  let(:updated_description) { 'This is what my collection is really about.' }
  let(:updated_related_links) do
    [
      {
        'text' => 'My new link',
        'url' => 'https://new.stanford.edu/'
      }
    ]
  end

  before do
    # On the second call, this will return the cocina object submitted to update.
    # This will allow us to test the updated values.
    allow(Sdr::Repository).to receive(:find).with(druid:).and_invoke(->(_arg) { cocina_object }, lambda { |_arg|
      @updated_cocina_object
    })
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    # It is already open.
    allow(Sdr::Repository).to receive(:open_if_needed) { |args| args[:cocina_object] }
    allow(Sdr::Repository).to receive(:update) do |args|
      @updated_cocina_object = args[:cocina_object]
    end

    create(:collection, druid:, user:)

    sign_in(user, groups:)
  end

  it 'edits a collection' do
    visit edit_collection_path(druid)

    expect(page).to have_css('h1', text: collection_title_fixture)

    find('.nav-link', text: 'Details').click
    expect(page).to have_field('Collection name', with: collection_title_fixture)

    fill_in('Collection name', with: updated_title)

    # Testing validation
    find('.nav-link', text: 'Details').click
    fill_in('collection_description', with: '')
    find('.nav-link', text: 'Deposit').click
    click_link_or_button('Deposit')
    expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')

    # Filling in abstract
    fill_in('collection_description', with: updated_description)

    # Filling in related content
    find('.nav-link', text: 'Related links').click
    fill_in('Link text', with: 'delete')
    fill_in('URL', with: 'me')
    # Test adding a new nested field
    click_link_or_button('+ Add another related link')
    fill_in('collection_related_links_attributes_1_text', with: updated_related_links.first['text'])
    fill_in('collection_related_links_attributes_1_url', with: updated_related_links.first['url'])
    # Test removing a nested field
    within('div[data-index="0"]') do
      find('button[data-action="click->nested-form#delete"]').click
    end

    # Clicking on Next to go to Participants tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Participants')
    expect(page).to have_text('Managers')
    fill_in('collection_managers_attributes_0_sunetid', with: 'stepking')
    fill_in('collection_depositors_attributes_0_sunetid', with: 'joehill')

    click_link_or_button('Save as draft')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: updated_title)
    expect(page).to have_content(updated_description)
    expect(page).to have_link(updated_related_links.first['text'], href: updated_related_links.first['url'])
    expect(page).to have_content('stepking@stanford.edu')
    expect(page).to have_content('joehill@stanford.edu')
    expect(page).to have_css('.status', text: 'New version in draft')
    expect(page).to have_link('Edit or deposit', href: edit_collection_path(druid))
  end
end
