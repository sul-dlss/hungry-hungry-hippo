# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a work deposit' do
  include_context 'with FAST connection'

  let(:query) { 'Biology' }
  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let(:version_status) do
    VersionStatus.new(status:
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, accessioning?: true,
                                                                         openable?: false, version: 1))
  end

  before do
    # Stubbing out for Deposit Job
    allow(Sdr::Repository).to receive(:register) do |args|
      cocina_params = args[:cocina_object].to_h
      cocina_params[:externalIdentifier] = druid
      cocina_params[:description][:purl] = Sdr::Purl.from_druid(druid:)
      cocina_params[:structural] = { isMemberOf: [collection_druid_fixture] }
      cocina_params[:administrative] = { hasAdminPolicy: Settings.apo }
      cocina_object = Cocina::Models.build(cocina_params)
      (@registered_cocina_object = Cocina::Models.with_metadata(cocina_object, 'abc123'))
    end
    allow(Sdr::Repository).to receive(:accession)

    # Stubbing out for show page
    allow(Sdr::Repository).to receive(:find).with(druid:).and_invoke(->(_arg) { @registered_cocina_object })
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    create(:collection, user:, druid: collection_druid_fixture, managers: [user],
                        custom_rights_statement_option: 'depositor_selects', doi_option: 'depositor_selects')
    sign_in(user)
  end

  it 'creates and deposits a work' do
    visit root_path
    click_link_or_button('Deposit to this collection')

    expect(page).to have_css('h1', text: 'Untitled deposit')

    # Testing tabs
    # Manage files tab is active, abstract is not
    expect(page).to have_css('.nav-link.active', text: 'Manage files')
    expect(page).to have_css('.nav-link:not(.active)', text: 'Abstract')
    # Manage files pane with form field is visible, abstract is not
    expect(page).to have_css('div.h4', text: 'Manage files')
    expect(page).to have_css('.dropzone', text: 'Select files to upload')
    expect(page).to have_no_text('Describe your deposit')

    # Adding a file
    find('.dropzone').drop('spec/fixtures/files/hippo.png')

    expect(page).to have_css('table#content-table td', text: 'hippo.png')

    # Filling in title
    find('.nav-link', text: 'Title & contact').click
    fill_in('work_title', with: title_fixture)
    fill_in('Contact email', with: contact_emails_fixture.first['email'])

    # Click Next to go to authors tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Authors')
    expect(page).to have_text('Author(s) to include in citation')

    # Enter two authors
    select('Creator', from: 'work_authors_attributes_0_person_role')
    fill_in('First name', with: 'Jane')
    fill_in('Last name', with: 'Stanford')
    click_link_or_button('Add another author')
    find('label[for=work_authors_attributes_1_role_type_organization]').click
    select('Author', from: 'work_authors_attributes_1_organization_role')
    fill_in(id: 'work_authors_attributes_1_organization_name', with: 'Stanford University')

    # Click Next to go to abstract tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Abstract')
    expect(page).to have_text('Abstract')

    # Filling in abstract & keywords
    fill_in('work_abstract', with: abstract_fixture)
    expect(page).to have_text('Keywords')
    fill_in('Keywords (one per box)', with: keywords_fixture.first['text'])

    # Click Next to go to work type tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Type of deposit')
    expect(page).to have_text('What type of content will you deposit?')

    choose('Text')
    check('Thesis')
    click_link_or_button('See more options')
    check('3D model')

    # Click Next to go to DOI tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'DOI')
    expect(page).to have_text('Do you want a DOI assigned to this work?')
    choose('No')

    # Clicking on Next to go to dates tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Dates (optional)')
    expect(page).to have_text('Enter dates related to your deposit')

    # Filling in dates
    within_fieldset('publication_date') do
      # Month and day are disabled initially.
      expect(page).to have_field('Year', disabled: false, text: '')
      expect(page).to have_field('Month', disabled: true)
      expect(page).to have_field('Day', disabled: true)
      # They become enabled as fields are filled in.
      fill_in('Year', with: '2024')
      select('June', from: 'Month')
      select('10', from: 'Day')
      # Clear
      click_link_or_button('Clear')
      expect(page).to have_field('Year', disabled: false, text: '')
      expect(page).to have_field('Month', disabled: true)
      expect(page).to have_field('Day', disabled: true)
      fill_in('Year', with: '2024')
      select('June', from: 'Month')
      select('10', from: 'Day')
    end

    # Clicking on Next to go to the citation tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Citation for this deposit (optional)')

    # Filling in citation
    expect(page).to have_text('Citation for this deposit')
    expect(page).to have_field('Select citation', disabled: true)
    choose('Enter custom citation - replaces autogenerated citation')
    fill_in('Select citation', with: citation_fixture)

    # Clicking on Next to go to related content tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Related content (optional)')

    # Filling in related works
    expect(page).to have_text('Related works')
    fill_in('Link for a related work (e.g., DOI, arXiv, PMID, PURL, or other URL)',
            with: related_works_fixture.second['identifier'])
    select('It consists of parts, one of which is', from: 'work_related_works_attributes_0_relationship')

    # Filling in related links
    expect(page).to have_text('Related links')
    fill_in('Link text', with: related_links_fixture.first['text'])
    fill_in('URL', with: related_links_fixture.first['url'])

    # Clicking on Next to go to access settings tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Access settings')
    expect(page).to have_css('.h5', text: 'Release date')
    choose('On this date')
    fill_in 'Release date', with: (Time.zone.today + 1.day).iso8601

    expect(page).to have_css('.h5', text: 'Individual file visibility')
    expect(page).to have_css('.h5', text: 'Download access')
    select('Everyone', from: 'work_access')

    # Clicking on Next to go to license tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'License and additional terms of use')

    # Selecting license
    expect(page).to have_select('License', selected: 'Apache-2.0')
    select('CC-BY-4.0 Attribution International', from: 'work_license')

    # Entering additional terms of use
    fill_in('Additional terms of use (optional)', with: custom_rights_statement_fixture)

    # Clicking on Next to go to Terms of Deposit
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Terms of deposit')
    expect(page).to have_css('.h4', text: 'Terms of deposit')
    expect(page).to have_text('You agreed to the SDR Terms of Deposit.')

    # Clicking on Next to go to Deposit
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Deposit')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_css('.status', text: 'Depositing')
    expect(page).to have_no_link('Edit or deposit')
  end
end
