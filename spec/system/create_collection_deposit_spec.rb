# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a collection deposit' do
  let(:druid) { collection_druid_fixture }
  let(:user) { create(:user) }
  let(:groups) { ['dlss:hydrus-app-collection-creators'] }
  let(:cocina_object) do
    cocina_object = build(:collection, title: collection_title_fixture, id: druid)
    Cocina::Models.with_metadata(cocina_object, 'abc123')
  end

  let(:version_status) do
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, accessioning?: true,
                                                                         openable?: false)
  end

  before do
    # Stubbing out for Deposit Job
    allow(Sdr::Repository).to receive(:register) do |args|
      cocina_params = args[:cocina_object].to_h
      cocina_params[:externalIdentifier] = druid
      cocina_params[:description][:purl] = Sdr::Purl.from_druid(druid:)
      cocina_object = Cocina::Models.build(cocina_params)
      Cocina::Models.with_metadata(cocina_object, 'abc123')
    end
    allow(Sdr::Repository).to receive(:accession)
    # Stubbing out for show page
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)

    sign_in(user, groups:)
  end

  it 'creates a collection' do
    visit root_path
    click_link_or_button('Create a new collection')

    expect(page).to have_css('h1', text: 'Untitled collection')

    # Testing tabs
    expect(page).to have_css('.nav-link.active', text: 'Title')
    expect(page).to have_css('.nav-link:not(.active)', text: 'Description')
    # Manage files pane with form field is visible, abstract is not
    expect(page).to have_css('div.h4', text: 'Title')
    expect(page).to have_no_text('Describe your collection')

    # Filling in title
    find('.nav-link', text: 'Title').click
    fill_in('collection_title', with: collection_title_fixture)

    # Click Next to go to abstract tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Description')
    expect(page).to have_text('Describe your collection')

    # Filling in abstract
    fill_in('collection_description', with: collection_description_fixture)

    # Clicking on Next to go to related content tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Related content (optional)')
    expect(page).to have_text('Related links')

    # Filling in related links
    fill_in('Link text', with: related_links_fixture.first['text'])
    fill_in('URL', with: related_links_fixture.first['url'])

    # Clicking on Next to go to Deposit
    click_link_or_button('Next')
    find('.nav-link', text: 'Deposit').click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Deposit')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: collection_title_fixture)
    expect(page).to have_css('.status', text: 'Depositing')
    expect(page).to have_no_link('Edit or deposit')
  end
end