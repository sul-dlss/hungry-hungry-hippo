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

  let(:version_status) do
    VersionStatus.new(status:
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, accessioning?: true,
                                                                         openable?: false, discardable?: false,
                                                                         version: 1))
  end

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
    expect(page).to have_css('div.h4', text: 'Collection details')

    # Filling in title, description, and contact email
    find('.nav-link', text: 'Details').click
    fill_in('collection_title', with: collection_title_fixture)
    fill_in('collection_description', with: collection_description_fixture)
    fill_in('Contact email', with: contact_emails_fixture.first['email'])

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
    expect(page).to have_select('License', selected: 'No License')
    find_by_id('collection_license').click
    select('CC-BY-4.0 Attribution International', from: 'collection_license')
    expect(page).to have_select('License', selected: 'CC-BY-4.0 Attribution International')

    # Clicking on Next to go to Participants tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Participants')
    expect(page).to have_text('Managers')
    expect(page).to have_field('SUNet ID', with: user.sunetid)
    fill_in('collection_managers_attributes_1_sunetid', with: 'stepking')
    fill_in('collection_depositors_attributes_0_sunetid', with: 'joehill')

    # Clicking on Next to go to Workflow
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Workflow')
    expect(page).to have_text('Review workflow')
    expect(page).to have_checked_field('No', with: false)
    find('label', text: 'Yes').click
    fill_in('collection_reviewers_attributes_0_sunetid', with: 'pennywise')

    # Clicking on Next to go to Deposit
    click_link_or_button('Next')
    find('.nav-link', text: 'Deposit', exact_text: true).click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')

    # Footer buttons
    expect(page).to have_no_button('Next')
    expect(page).to have_link('Cancel')

    click_link_or_button('Deposit')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: collection_title_fixture)
    expect(page).to have_css('.status', text: 'Depositing')
    expect(page).to have_no_link('Edit or deposit')
  end
end
