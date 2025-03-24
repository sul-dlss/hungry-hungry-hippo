# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a collection deposit' do
  let(:druid) { collection_druid_fixture }
  let(:user) { create(:user, name: 'John Swithen', email_address: 'jswithen@stanford.edu') }
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

    create(:user, name: 'Stephen King', email_address: 'stepking@stanford.edu')
    # Note that Joe Hill is not created yet.
    create(:user, name: 'Pennywise', email_address: 'pennywise@stanford.edu')

    allow(AccountService).to receive(:call)
      .with(sunetid: 'stepking')
      .and_return(AccountService::Account.new(name: 'Stephen King', sunetid: 'stepking'))
    allow(AccountService).to receive(:call)
      .with(sunetid: 'joehill')
      .and_return(AccountService::Account.new(name: 'Joe Hill', sunetid: 'joehill'))
    allow(AccountService).to receive(:call)
      .with(sunetid: 'pennywise')
      .and_return(AccountService::Account.new(name: 'Pennywise', sunetid: 'pennywise'))
    allow(AccountService).to receive(:call).with(sunetid: 'notjoehill').and_return(nil)

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

    # Clicking on Next to go to Terms of Use tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Terms of use')
    expect(page).to have_checked_field('No, do not include a custom use statement.')
    expect(page).to have_field(id: 'collection_provided_custom_rights_statement', disabled: true)

    # Fill in a custom rights statement (test JS that enables the textarea)
    find('label', text: 'Yes, include the following custom use statement for every deposit in this collection.').click
    expect(page).to have_field(id: 'collection_provided_custom_rights_statement', disabled: false)
    fill_in('collection_provided_custom_rights_statement', with: 'My custom rights statement')

    # Clicking on Next to go to Participants tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Participants')
    expect(page).to have_text('Managers')
    form_instances = page.all('.form-instance')
    within(form_instances[0]) do
      expect(page).to have_css('p', text: 'jswithen: John Swithen')
    end

    fill_in('managers-textarea', with: 'stepking@stanford.edu')
    click_link_or_button('Add managers')
    expect(page).to have_css('.participant-label', text: 'stepking: Stephen King')

    fill_in('depositors-textarea', with: 'notjoehill, joehill')
    click_link_or_button('Add depositors')
    expect(page).to have_css('.participant-label', text: 'joehill: Joe Hill')
    expect(page).to have_field('depositors-textarea', with: 'notjoehill')

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
    fill_in('reviewers-textarea', with: 'pennywise')
    click_link_or_button('Add reviewers')
    expect(page).to have_css('.participant-label', text: 'pennywise: Pennywise')

    # Clicking on Next to go to the type of deposit tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Type of deposit (optional)')
    expect(page).to have_no_field('Other', type: 'radio')
    choose('Text')
    check('Capstone')
    check('Thesis')

    # Clicking on Next to go to works contact email tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Contact email for deposits (optional)')
    expect(page).to have_text('Add contact email for all deposits (optional)')
    fill_in('collection_works_contact_email', with: works_contact_email_fixture)

    # Clicking on Next to go to the contributors tab
    click_link_or_button('Next')
    # Enter two contributors
    select('Creator', from: 'Role')
    within('.orcid-section') do
      find('label', text: 'Enter name manually').click
    end
    fill_in('First name', with: 'Jane')
    fill_in('Last name', with: 'Stanford')

    click_link_or_button('Add another contributor')
    form_instance = page.all('.form-instance').last
    within(form_instance) do
      find('label', text: 'Organization').click
      select('Author', from: 'Role')
      fill_in('Organization name', with: 'Stanford University')
    end

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

    # Has work types and subtypes
    expect(page).to have_text('Text')
    expect(page).to have_text('Capstone, Thesis')

    # Has contact email for deposits
    expect(page).to have_text(works_contact_email_fixture)

    # Contributors
    within('#contributors-table') do
      expect(page).to have_css('td', text: 'Jane Stanford')
      expect(page).to have_css('td', text: 'Stanford University')
    end

    # License
    expect(page).to have_css('th', text: 'License')
    expect(page).to have_css('td', text: 'License required: CC-BY-4.0 Attribution International')

    # Review workflow
    within('#review-workflow-table') do
      expect(page).to have_css('td', text: 'On')
      expect(page).to have_css('th', text: 'Reviewers')
      expect(page).to have_css('td ul li', text: 'pennywise: Pennywise')
    end

    # Terms of use
    expect(page).to have_css('th', text: 'Additional terms of use')
    expect(page).to have_css('td', text: 'My custom rights statement')

    # Joe Hill was created
    expect(User.find_by(email_address: 'joehill@stanford.edu', name: 'Joe Hill')).to be_present
  end
end
