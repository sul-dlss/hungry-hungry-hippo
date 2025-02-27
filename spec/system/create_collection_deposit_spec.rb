# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a collection deposit' do
  let(:druid) { collection_druid_fixture }
  let(:user) { create(:user) }
  let(:manager) { create(:user) }
  let(:groups) { ['dlss:hydrus-app-collection-creators'] }
  let(:cocina_object) do
    cocina_object = build(:collection, title: collection_title_fixture, id: druid)
    Cocina::Models.with_metadata(cocina_object, 'abc123')
  end

  let(:version_status) { build(:first_accessioning_version_status) }

  before do
    # Stubbing out for Deposit Job
    allow(Sdr::Repository).to receive(:register) do |args|
      cocina_params = args[:cocina_object].to_h
      cocina_params[:externalIdentifier] = druid
      cocina_params[:description][:purl] = Sdr::Purl.from_druid(druid:)
      cocina_params[:administrative] = { hasAdminPolicy: Settings.apo }
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
    visit dashboard_path
    click_link_or_button('Create a new collection')

    # Breadcrumb
    expect(page).to have_link('Dashboard', href: dashboard_path)
    expect(page).to have_css('.breadcrumb-item', text: 'Untitled collection')

    expect(page).to have_css('h1', text: 'Untitled collection')

    # Footer buttons
    expect(page).to have_button('Next')
    expect(page).to have_link('Cancel')

    # Testing tabs
    expect(page).to have_css('.nav-link.active', text: 'Details')
    expect(page).to have_css('.nav-link:not(.active)', text: 'Related links (optional)')
    # Manage files pane with form field is visible, abstract is not
    expect(page).to have_css('h2', text: 'Collection details')

    # Filling in title, description, and contact email
    find('.nav-link', text: 'Details').click
    fill_in('collection_title', with: collection_title_fixture)
    fill_in('collection_description', with: collection_description_fixture)
    expect(page).to have_field('Contact email', with: user.email_address)

    # Clicking on Next to go to related content tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Related links (optional)')
    expect(page).to have_text('Links to related content (optional)')

    # Filling in related links
    fill_in('Link text', with: related_links_fixture.first['text'])
    fill_in('URL', with: related_links_fixture.first['url'])

    # Clicking on Next to go to access settings tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Access settings')
    expect(page).to have_text('Manage release of deposits for discovery and download')
    expect(page).to have_checked_field('Immediately')
    expect(page).to have_select('Release duration', selected: 'Select an option')

    # Clicking on Next to go to License tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'License')
    expect(page).to have_text('License')
    expect(page).to have_checked_field('Require license for all deposits')
    expect(page).to have_select('Required license', selected: 'Select required license...')
    select('CC-BY-4.0 Attribution International', from: 'Required license')

    # Clicking on Next to go to Participants tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Participants')
    expect(page).to have_text('Managers')
    expect(page).to have_field('SUNet ID', with: user.sunetid)
    fill_in('collection_managers_attributes_1_sunetid', with: 'stepking')
    fill_in('collection_depositors_attributes_0_sunetid', with: 'joehill')
    expect(page).to have_checked_field('Send email to Collection Managers and Reviewers ' \
                                       '(see Workflow section of form) when participants are added/removed',
                                       with: '1')
    expect(page).to have_checked_field('Send email to Depositors whose status has changed.', with: '1')

    # Clicking on Next to go to Workflow
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Workflow')
    expect(page).to have_text('Review workflow')
    expect(page).to have_checked_field('No', with: false)
    find('label', text: 'Yes').click
    fill_in('collection_reviewers_attributes_0_sunetid', with: 'pennywise')

    # Clicking on Next to go to Deposit
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Save your collection')

    # Footer buttons
    expect(page).to have_no_button('Next')
    expect(page).to have_link('Cancel')

    click_link_or_button('Save', class: 'btn-primary')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: collection_title_fixture)
    expect(page).to have_no_link('Edit')

    # License
    expect(page).to have_css('th', text: 'Required license')
    expect(page).to have_css('td', text: 'CC-BY-4.0 Attribution International')
  end
end
