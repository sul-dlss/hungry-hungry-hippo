# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit a collection' do
  # Using mapping fixtures because it provides a roundtrippable DRO.
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }
  let(:manager) { create(:user, name: 'Al Borland', email_address: 'alborland@stanford.edu') }

  let(:cocina_object) do
    collection_with_metadata_fixture
  end

  let(:version_status) { build(:draft_version_status, version: cocina_object.version) }
  let(:accessioning_version_status) { build(:accessioning_version_status, version: cocina_object.version) }

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
      cocina_object
    }, lambda { |_arg|
         @updated_cocina_object
       })
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status, accessioning_version_status)
    # It is already open.
    allow(Sdr::Repository).to receive(:open_if_needed) { |args| args[:cocina_object] }
    allow(Sdr::Repository).to receive(:update) do |args|
      @updated_cocina_object = args[:cocina_object]
    end
    allow(Sdr::Repository).to receive(:accession)
    allow(Sdr::Event).to receive(:list).and_return([])

    create(:collection, :with_required_types, :with_required_contact_email, druid:, managers: [manager])

    create(:user, name: 'Stephen King', email_address: 'stepking@stanford.edu')
    # Joe Hill is not created yet.
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

    sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
  end

  it 'edits a collection' do
    visit edit_collection_path(druid, tab: 'related_links')

    expect(page).to have_css('h1', text: collection_title_fixture)

    expect(page).to have_css('.nav-link.active', text: 'Related links (optional)')

    find('.nav-link', text: 'Details').click
    expect(page).to have_field('Collection name', with: collection_title_fixture)

    fill_in('Collection name', with: updated_title)

    # Testing validation
    find('.nav-link', text: 'Details').click
    fill_in('collection_description', with: '')
    find('.nav-link', text: 'Save your collection', exact_text: true).click
    click_link_or_button('Save', class: 'btn-primary')
    expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')

    # Filling in abstract
    fill_in('collection_description', with: updated_description)

    # Filling in related content
    find('.nav-link', text: 'Related links (optional)').click
    form_instances = all('.form-instance')
    within form_instances[0] do
      fill_in('Link text', with: 'delete')
      fill_in('URL', with: 'me')
    end
    # Test adding a new nested field
    click_link_or_button('+ Add another related link')
    form_instances = all('.form-instance')
    within form_instances[2] do
      fill_in('Link text', with: updated_related_links.first['text'])
      fill_in('URL', with: updated_related_links.first['url'])
    end
    # Test removing a nested field
    within(form_instances[0]) do
      find('button[data-action="click->nested-form#delete"]').click
    end

    # Clicking on Next to go to access settings tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Access settings')
    expect(page).to have_content('Manage release of deposits for discovery and download')
    expect(page).to have_checked_field('Depositor selects a date up to')
    expect(page).to have_select('Release duration', selected: '1 year in the future')
    expect(page).to have_checked_field('Yes, a DOI will be assigned to each deposit in this collection.')
    # change the release duration to Immediately
    find_by_id('collection_release_option_immediate').click
    expect(page).to have_select('Release duration', selected: 'Select an option')
    # change it back to set a release duration
    find_by_id('collection_release_option_depositor_selects').click
    select('3 years in the future', from: 'collection_release_duration')
    expect(page).to have_select('Release duration', selected: '3 years in the future')

    # Clicking on Next to go to License tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'License')
    expect(page).to have_checked_field('Require license for all deposits')
    expect(page).to have_select('Required license', selected: 'CC-BY-4.0 Attribution International')
    choose('Depositor selects license')
    select('CC-BY-4.0 Attribution International', from: 'Default license')

    # Clicking on Next to go to Terms of Use tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Terms of use')
    expect(page).to have_checked_field('Yes, include the following custom use statement')
    expect(page).to have_field('collection[provided_custom_rights_statement]', with: 'My custom rights statement')

    # Clicking on Next to go to Participants tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Participants')

    # There is a manager form instance only
    form_instances = all('.form-instance')
    expect(form_instances.count).to eq(1)

    # Remove the manager
    within form_instances[0] do
      expect(page).to have_css('.participant-label', text: 'Al Borland (alborland)') # Manager
      find('button[data-action="click->nested-form#delete"]').click
    end
    expect(page).to have_no_text('Al Borland (alborland)')

    fill_in('managers-textarea', with: 'stepking@stanford.edu')
    click_link_or_button('Add managers')
    expect(page).to have_css('.participant-label', text: 'Stephen King (stepking)')

    # Fill in the depositor form
    fill_in('depositors-textarea', with: 'joehill')
    click_link_or_button('Add depositors')
    expect(page).to have_css('.participant-label', text: 'Joe Hill (joehill)')

    find('label', text: 'Send email to Collection Managers and Reviewers ' \
                        '(see Workflow section of form) when participants are added/removed').click
    find('label', text: 'Send email to Depositors who have been added or removed.').click

    # Clicking on Next to go to Workflow
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Workflow')
    expect(page).to have_text('Review workflow')
    expect(page).to have_checked_field('No', with: false)
    find('label', text: 'Yes').click

    fill_in('reviewers-textarea', with: 'pennywise')
    click_link_or_button('Add reviewers')
    expect(page).to have_css('.participant-label', text: 'Pennywise (pennywise')

    # Clicking on Next to go to type of deposit tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Type of deposit (optional)')
    expect(page).to have_field('Image', checked: true)
    expect(page).to have_field('Data', checked: true)
    expect(page).to have_field('Photograph', checked: true)
    choose('No required work type')
    expect(page).to have_no_field('Photograph')

    # Clicking on Next to go to works contact email tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Contact email for deposits (optional)')
    expect(page).to have_field('Contact email to be included in all deposits in this collection',
                               with: works_contact_email_fixture)
    fill_in('collection_works_contact_email', with: '')

    # Clicking on Next to go to contributors tab
    click_link_or_button('Next')
    # There is a blank contributor form.
    expect(page).to have_css('.form-instance')

    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Save your collection')
    click_link_or_button('Save', class: 'btn-primary')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: updated_title)
    expect(page).to have_content(updated_description)
    expect(page).to have_link(updated_related_links.first['text'], href: updated_related_links.first['url'])

    # Work types
    expect(page).to have_no_text('Image')
    expect(page).to have_no_text('Data')

    # Has contact email for deposits
    expect(page).to have_no_text(works_contact_email_fixture)

    # Access settings
    expect(page).to have_content('3 years in the future')

    # Participants
    expect(page).to have_content('Stephen King (stepking)')
    expect(page).to have_content('Joe Hill (joehill)')
    expect(page).to have_content('Pennywise (pennywise)')

    # License
    expect(page).to have_css('th', text: 'License')
    expect(page).to have_css('td', text: 'Depositor selects. Default license: CC-BY-4.0 Attribution International')
    expect(page).to have_no_content('aborland@stanford.edu')

    # Joe Hill was created
    expect(User.find_by(email_address: 'joehill@stanford.edu', name: 'Joe Hill')).to be_present
  end
end
