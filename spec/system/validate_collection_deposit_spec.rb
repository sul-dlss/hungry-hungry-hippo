# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Validate a collection deposit' do
  include CollectionMappingFixtures

  before do
    allow(DepositCollectionJob).to receive(:perform_later)
  end

  context 'when a new collection with validation errors' do
    let(:user) { create(:user) }
    let(:groups) { ['dlss:hydrus-app-collection-creators'] }

    before do
      sign_in(user, groups:)
    end

    it 'validates a collection' do
      visit new_collection_path

      expect(page).to have_css('h1', text: 'Untitled collection')

      # Filling in title
      find('.nav-link', text: 'Details').click
      fill_in('collection_title', with: collection_title_fixture)
      fill_in('Contact email', with: contact_emails_fixture.first['email'])

      # Description is required for deposit, but skipping.

      # Clicking on related content tab & filling in invalid related link
      find('.nav-link', text: 'Related links (optional)').click
      expect(page).to have_css('.nav-link.active', text: 'Related links (optional)')
      fill_in('Link text', with: 'foo.com')

      # Clicking on access settings & selecting depositor selects without a release duration
      find('.nav-link', text: 'Access settings').click
      find_by_id('collection_release_option_depositor_selects').click
      expect(page).to have_select('Release duration', selected: 'Select an option')

      # Depositing the collection
      find('.nav-link', text: 'Save your collection', exact_text: true).click
      expect(page).to have_css('.nav-link.active', text: 'Save your collection')
      click_link_or_button('Save', class: 'btn-primary')
      expect(page).to have_css('h1', text: collection_title_fixture)
      expect(page).to have_current_path(new_collection_path)

      # Alert
      expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')

      # Description is marked invalid
      expect(page).to have_css('.nav-link.active', text: 'Details')
      expect(page).to have_css('textarea.is-invalid#collection_description')
      expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")

      # Make the description valid
      fill_in('Description', with: collection_description_fixture)

      # Related content is marked invalid
      expect(page).to have_css('.nav-link', text: 'Related links (optional)')
      find('.nav-link', text: 'Related links (optional)').click
      expect(page).to have_field('collection_related_links_attributes_0_url', class: 'is-invalid')
      expect(page).to have_css('.invalid-feedback.is-invalid', text: 'is not a valid URL')

      # Make the related link valid
      fill_in('Link text', with: related_links_fixture.first['text'])
      fill_in('URL', with: related_links_fixture.first['url'])

      # Access setting for release duration is marked invalid
      find('.nav-link', text: 'Access settings').click
      expect(page).to have_css('.invalid-feedback.is-invalid', text: 'select a valid duration for release')
      select('3 years in the future', from: 'collection_release_duration')
      expect(page).to have_select('Release duration', selected: '3 years in the future')

      # Required license is marked invalidate
      find('.nav-link', text: 'License').click
      expect(page).to have_css('.invalid-feedback.is-invalid', text: 'can\'t be blank')
      select('No License', from: 'Required license')

      # Try to deposit again
      find('.nav-link', text: 'Save your collection').click
      expect(page).to have_css('.nav-link.active', text: 'Save your collection')
      click_link_or_button('Save', class: 'btn-primary')
      expect(page).to have_css('li', text: collection_title_fixture)
      expect(page).to have_current_path(%r{/collections/wait/\d+})
      expect(DepositCollectionJob).to have_received(:perform_later)
    end
  end

  context 'when nested field has validation errors' do
    let(:druid) { collection_druid_fixture }
    let(:manager) { create(:user, name: 'Al Borland', email_address: 'alborland@stanford.edu') }

    let(:cocina_object) do
      collection_with_metadata_fixture
    end

    let(:version_status) { build(:draft_version_status, version: cocina_object.version) }

    before do
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)

      create(:collection, druid:, managers: [manager])

      sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
    end

    it 'validates a collection' do
      visit edit_collection_path(druid, tab: 'related_links')

      expect(page).to have_css('h1', text: collection_title_fixture)

      find('.nav-link', text: 'Contributors').click
      select('Creator', from: 'Role')
      within('.orcid-section') do
        find('label', text: 'Enter name manually').click
      end
      fill_in('First name', with: 'Jane')

      find('.nav-link', text: 'Save your collection').click
      click_link_or_button('Save', class: 'btn-primary')

      expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')
    end
  end
end
