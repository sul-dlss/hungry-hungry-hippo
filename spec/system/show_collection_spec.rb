# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show a collection' do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }
  let(:bare_druid) { collection_bare_druid_fixture }
  let(:manager) { create(:user) }
  let(:depositor) { create(:user) }

  let!(:collection) do
    create(:collection, :with_review_workflow, :with_works, :with_required_types,
           :with_required_contact_email, works_count: 3, reviewers_count: 2, druid:, title: collection_title_fixture,
                                         contributors: [contributor], managers: [manager], depositors: [depositor])
  end
  let(:works) { collection.works.order(:title) }

  let(:cocina_object) { collection_with_metadata_fixture }
  let(:version_status) { build(:openable_version_status) }
  let(:contributor) { create(:person_contributor, first_name: 'Jane', last_name: 'Stanford', orcid: 'https://orcid.org/0001-0002-0003-0004') }

  let(:events) do
    # This is testing the case in which the data is a cocina object (e.g., registration event)
    [Dor::Services::Client::Events::Event.new(event_type: 'version_close', timestamp: '2020-01-27T19:10:27.291Z',
                                              data: { 'who' => 'lstanfordjr', 'cocinaVersion' => '0.1',
                                                      'description' => 'cocina description' })]
  end

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Repository).to receive(:statuses)
      .and_return(collection.works.where.not(druid: nil).to_h { |work| [work.druid, version_status] })
    allow(Sdr::Event).to receive(:list).with(druid:).and_return(events)

    collection.works.first.request_review!
    collection.works[1].update(user: depositor)
  end

  context 'when a manager' do
    before do
      sign_in(manager)
    end

    it 'shows a collection' do
      visit collection_path(druid)

      # Breadcrumb
      expect(page).to have_link('Dashboard', href: dashboard_path)
      expect(page).to have_css('.breadcrumb-item', text: collection.title)

      # Tabs
      expect(page).to have_css('.nav-link.active', text: 'Collection information')

      # Header
      expect(page).to have_css('h1', text: collection.title)
      expect(page).to have_link('Edit', href: edit_collection_path(druid))
      expect(page).to have_link('Deposit to this collection', href: new_work_path(collection_druid: druid))

      # Collection information
      within('table#info-table') do
        expect(page).to have_css('caption', text: 'Collection information')
        expect(page).to have_css('th', text: 'Public webpage')
        expect(page).to have_link("https://sul-purl-stage.stanford.edu/#{bare_druid}", href: "https://sul-purl-stage.stanford.edu/#{bare_druid}")
        expect(page).to have_css('th', text: 'Created by')
        expect(page).to have_css('td', text: collection.user.name)
        expect(page).to have_css('th', text: 'Collection created')
      end

      # Details table
      within('table#details-table') do
        expect(page).to have_css('caption', text: 'Details')
        expect(page).to have_link('Edit', href: edit_collection_path(druid, tab: 'details'))
        expect(page).to have_css('tr', text: 'Collection name')
        expect(page).to have_css('td', text: collection.title)
        expect(page).to have_css('tr', text: 'Description')
        expect(page).to have_css('td', text: collection_description_fixture)
        expect(page).to have_css('tr', text: 'Contact emails')
        expect(page).to have_css('td', text: contact_emails_fixture.pluck(:email).join(', '))
      end

      # Related Content table
      within('table#related-content-table') do
        expect(page).to have_css('caption', text: 'Links to related information')
        expect(page).to have_link('Edit', href: edit_collection_path(druid, tab: 'related_links'))
        expect(page).to have_css('tr', text: 'Related links')
        expect(page).to have_css('td', text: related_links_fixture.first['text'])
      end

      # Work type table
      within('table#work-type-table') do
        expect(page).to have_css('caption', text: 'Type of deposits')
        expect(page).to have_link('Edit', href: edit_collection_path(druid, tab: 'types'))
        expect(page).to have_css('tr', text: 'Deposit type')
        expect(page).to have_css('td', text: work_type_fixture)
        expect(page).to have_css('tr', text: 'Deposit subtypes')
        expect(page).to have_css('td', text: work_subtypes_fixture.join(', '))
      end

      # Works contact email table
      within('table#works-contact-email-table') do
        expect(page).to have_css('caption', text: 'Contact email for deposits')
        expect(page).to have_link('Edit', href: edit_collection_path(druid, tab: 'works_contact_email'))
        expect(page).to have_css('tr', text: 'Contact email')
        expect(page).to have_css('td', text: works_contact_email_fixture)
      end

      # Contributors table
      within('table#contributors-table') do
        expect(page).to have_css('caption', text: 'Contributors')
        expect(page).to have_link('Edit', href: edit_collection_path(druid, tab: 'contributors'))
        expect(page).to have_css('th', text: 'Contributor')
        expect(page).to have_css('th', text: 'ORCID')
        expect(page).to have_css('th', text: 'Role')
        within('tbody tr:nth-of-type(1)') do
          expect(page).to have_css('td:nth-of-type(1)', text: 'Jane Stanford')
          expect(page).to have_css('td:nth-of-type(2)', text: 'https://orcid.org/0001-0002-0003-0004')
          expect(page).to have_css('td:nth-of-type(3)', text: 'Author')
        end
      end

      # Release and visibility table
      within('table#release-visibility-table') do
        expect(page).to have_css('caption', text: 'Release and visibility')
        expect(page).to have_link('Edit', href: edit_collection_path(druid, tab: 'access'))
        expect(page).to have_css('tr', text: 'Release')
        expect(page).to have_css('td', text: 'Depositor selects release date no more than 1 year in the future')
        expect(page).to have_css('tr', text: 'Visibility')
        expect(page).to have_css('td', text: 'Depositor selects')
        expect(page).to have_css('tr', text: 'DOI Assignment')
        expect(page).to have_css('td', text: 'Yes')
      end

      # Terms of use and licenses table
      within('table#terms-licenses-table') do
        expect(page).to have_css('caption', text: 'Terms of use and licenses')
        expect(page).to have_link('Edit', href: edit_collection_path(druid, tab: 'license'))
        expect(page).to have_css('tr', text: 'Terms of use')
        expect(page).to have_css('td', text: 'User agrees that')
        expect(page).to have_css('tr', text: 'Additional terms of use')
        expect(page).to have_css('td', text: 'My custom rights statement')
        expect(page).to have_css('tr', text: 'License')
        expect(page).to have_css('td', text: 'License required: CC-BY-4.0 Attribution International')
      end

      # Participants table
      within('table#participants-table') do
        expect(page).to have_css('caption', text: 'Collection participants')
        expect(page).to have_link('Edit', href: edit_collection_path(druid, tab: 'participants'))
        expect(page).to have_css('tr', text: 'Managers')
        manager = collection.managers.first
        expect(page).to have_css('td ul li', text: "#{manager.sunetid}: #{manager.name}")
        expect(page).to have_css('tr', text: 'Depositors')
        depositor = collection.depositors.first
        expect(page).to have_css('td ul li', text: "#{depositor.sunetid}: #{depositor.name}")
      end

      # Review workflow table
      within('table#review-workflow-table') do
        expect(page).to have_css('caption', text: 'Review workflow')
        expect(page).to have_link('Edit', href: edit_collection_path(druid, tab: 'workflow'))
        expect(page).to have_css('tr', text: 'Status')
        expect(page).to have_css('td', text: 'On')
        expect(page).to have_css('tr', text: 'Reviewers')
        collection.reviewers.each do |reviewer|
          expect(page).to have_css('td ul li', text: "#{reviewer.sunetid}: #{reviewer.name}")
        end
      end

      # History table
      within('table#history-table') do
        expect(page).to have_css('caption', text: 'History')
        expect(page).to have_css('th', text: 'Action')
        expect(page).to have_css('th', text: 'Modified by')
        expect(page).to have_css('th', text: 'Last modified')
        expect(page).to have_css('th', text: 'Description of changes')
        expect(page).to have_css('tr', text: 'Deposited')
        expect(page).to have_css('td', text: 'lstanfordjr')
        expect(page).to have_css('td', text: 'January 27, 2020 19:10')
        expect(page).to have_no_css('td', text: 'cocina description')
      end

      # Change tab
      click_link_or_button('Deposits')
      expect(page).to have_css('.nav-link.active', text: 'Deposits')
      expect(page).to have_button('Sort by')

      # Deposits table
      within('table#deposits-table') do
        expect(page).to have_css('th', text: 'Deposit')
        expect(page).to have_css('th', text: 'Owner')
        expect(page).to have_css('th', text: 'Status')
        expect(page).to have_css('th', text: 'Modified')
        expect(page).to have_css('th', text: 'Link for sharing')
        all_trs = page.all('tbody tr')
        expect(all_trs.size).to eq(2) # Since paginated
        work = works[0]
        row = all_trs.find { |tr| tr.has_css?('td:nth-of-type(1)', text: work.title) }
        within(row) do
          expect(page).to have_css('td:nth-of-type(2)', text: work.user.name)
          expect(page).to have_css('td:nth-of-type(3)', text: 'Pending review')
          expect(page).to have_css('td:nth-of-type(5)', text: "https://doi.org/10.80343/#{work.druid.delete_prefix('druid:')}")
        end
        work = works[1]
        row = all_trs.find { |tr| tr.has_css?('td:nth-of-type(1)', text: work.title) }
        within(row) do
          expect(page).to have_css('td:nth-of-type(3)', text: 'Deposited')
        end
      end

      within('div#deposits-pane') do
        # test the >0 and 0 results cases, leave more exhaustive testing of search fields
        # to the request specs

        fill_in('Search', with: works.to_a[0].title)
        click_link_or_button 'Search'
        expect(page).to have_css('td a', text: works.to_a[0].title)
        expect(page).to have_no_css('td a', text: works.to_a[1].title)
        expect(page).to have_no_css('td a', text: works.to_a[2].title)

        fill_in('Search', with: 'asdfsdf')
        click_link_or_button 'Search'
        expect(page).to have_css('p', text: "No deposits to this collection match the search: 'asdfsdf'.")
        expect(page).to have_no_css('td a', text: works.to_a[0].title)
        expect(page).to have_no_css('td a', text: works.to_a[1].title)
        expect(page).to have_no_css('td a', text: works.to_a[2].title)

        fill_in('Search', with: '') # reset form to no search terms for rest of test
        click_link_or_button 'Search'
      end

      # Next page
      click_link_or_button('Next')

      within('table#deposits-table') do
        expect(page).to have_css('th', text: 'Deposit')
        expect(page).to have_css('th', text: 'Owner')
        expect(page).to have_css('th', text: 'Status')
        expect(page).to have_css('th', text: 'Modified')
        expect(page).to have_css('th', text: 'Link for sharing')
        all_trs = page.all('tbody tr')
        expect(all_trs.size).to eq(1) # Since paginated
        within(all_trs.first) do
          expect(page).to have_css('td:nth-of-type(1)', text: works[2].title)
          expect(page).to have_css('td:nth-of-type(3)', text: 'Saving')
          expect(page).to have_css('td:nth-of-type(5)', exact_text: '')
        end
      end

      # Sort by deposit descending to re-order works
      click_link_or_button('Sort by')
      click_link_or_button('Deposit (ascending)')
      within('table#deposits-table') do
        all_trs = page.all('tbody tr')
        within(all_trs.first) do
          expect(page).to have_css('td:nth-of-type(1)', text: works[0].title)
        end
      end
    end
  end

  context 'when depositor' do
    before do
      sign_in(depositor)
    end

    it 'shows a collection' do
      visit collection_path(druid)

      # Header
      expect(page).to have_css('h1', text: collection.title)
      expect(page).to have_no_link('Edit')
      expect(page).to have_link('Deposit to this collection', href: new_work_path(collection_druid: druid))

      # Only owned works are shown
      click_link_or_button('Deposits')
      expect(page).to have_css('.nav-link.active', text: 'Deposits')

      # Deposits table
      within('table#deposits-table') do
        all_trs = page.all('tbody tr')
        expect(all_trs.size).to eq(1)
      end

      # Only owned works make it to search results
      within('div#deposits-pane') do
        # test the >0 and 0 results cases, leave more exhaustive testing of search fields
        # to the request specs

        fill_in('Search', with: works.to_a[0].title)
        click_link_or_button 'Search'
        expect(page).to have_no_css('td a', text: works.to_a[0].title)
        expect(page).to have_no_css('td a', text: works.to_a[1].title)
        expect(page).to have_no_css('td a', text: works.to_a[2].title)
        expect(page).to have_css('p',
                                 text: "No deposits to this collection match the search: '#{works.to_a[0].title}'.")

        # the user in question only owns this work
        fill_in('Search', with: works.to_a[1].druid)
        click_link_or_button 'Search'
        expect(page).to have_css('td a', text: works.to_a[1].title)
        expect(page).to have_no_css('td a', text: works.to_a[0].title)
        expect(page).to have_no_css('td a', text: works.to_a[2].title)

        fill_in('Search', with: '') # reset form to no search terms
        click_link_or_button 'Search'
      end
    end
  end
end
