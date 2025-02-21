# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show a collection' do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }
  let(:bare_druid) { collection_bare_druid_fixture }
  let(:user) { collection.user }
  let!(:collection) do
    create(:collection, :with_review_workflow, :with_depositors, :with_managers, :with_works,
           works_count:, reviewers_count: 2, druid:, title: collection_title_fixture)
  end
  let(:works_count) { 3 }
  let(:cocina_object) { collection_with_metadata_fixture }
  let(:version_status) { build(:openable_version_status) }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Repository).to receive(:statuses)
      .and_return(collection.works.where.not(druid: nil).to_h { |work| [work.druid, version_status] })

    collection.works.first.request_review!
    sign_in(user)
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
    expect(page).to have_css('i.bi-pencil')
    expect(page).to have_link('Edit', href: edit_collection_path(druid))
    expect(page).to have_link('Deposit to this collection', href: new_work_path(collection_druid: druid))

    # Collection information
    within('table#info-table') do
      expect(page).to have_css('caption', text: 'Collection information')
      expect(page).to have_css('th', text: 'PURL')
      expect(page).to have_link("https://sul-purl-stage.stanford.edu/#{bare_druid}", href: "https://sul-purl-stage.stanford.edu/#{bare_druid}")
      expect(page).to have_css('th', text: 'Created by')
      expect(page).to have_css('td', text: collection.user.name)
      expect(page).to have_css('th', text: 'Collection created')
    end

    # Details table
    within('table#details-table') do
      expect(page).to have_css('caption', text: 'Details')
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
      expect(page).to have_css('tr', text: 'Related links')
      expect(page).to have_css('td', text: related_links_fixture.first['text'])
    end

    # Release and visibility table
    within('table#release-visibility-table') do
      expect(page).to have_css('caption', text: 'Release and visibility')
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
      expect(page).to have_css('tr', text: 'Terms of use')
      expect(page).to have_css('td', text: 'User agrees that')
      expect(page).to have_css('tr', text: 'Additional terms of use')
      expect(page).to have_css('td', text: 'My custom rights statement')
      expect(page).to have_css('tr', text: 'Required license')
      expect(page).to have_css('td', text: 'CC-BY-4.0 Attribution International')
    end

    # Participants table
    within('table#participants-table') do
      expect(page).to have_css('caption', text: 'Collection participants')
      expect(page).to have_css('tr', text: 'Managers')
      expect(page).to have_css('td', text: collection.managers.first.email_address)
      expect(page).to have_css('tr', text: 'Depositors')
      expect(page).to have_css('td', text: collection.depositors.first.email_address)
    end

    # Review workflow table
    within('table#review-workflow-table') do
      expect(page).to have_css('caption', text: 'Review workflow')
      expect(page).to have_css('tr', text: 'Status')
      expect(page).to have_css('td', text: 'On')
      expect(page).to have_css('tr', text: 'Reviewers')
      expect(page).to have_css('td', text: collection.reviewers.pluck(:email_address).join(', '))
    end

    # Change tab
    click_link_or_button('Deposits')
    expect(page).to have_css('.nav-link.active', text: 'Deposits')

    # Deposits table
    within('table#deposits-table') do
      expect(page).to have_css('th', text: 'Deposit')
      expect(page).to have_css('th', text: 'Owner')
      expect(page).to have_css('th', text: 'Status')
      expect(page).to have_css('th', text: 'Modified')
      expect(page).to have_css('th', text: 'Link for sharing')
      all_trs = page.all('tbody tr')
      work = collection.works[0]
      row = all_trs.find { |tr| tr.has_css?('td:nth-of-type(1)', text: work.title) }
      within(row) do
        expect(page).to have_css('td:nth-of-type(2)', text: work.user.name)
        expect(page).to have_css('td:nth-of-type(3)', text: 'Pending review')
        expect(page).to have_css('td:nth-of-type(5)', text: "https://doi.org/10.80343/#{work.druid.delete_prefix('druid:')}")
      end
      work = collection.works[1]
      row = all_trs.find { |tr| tr.has_css?('td:nth-of-type(1)', text: work.title) }
      within(row) do
        expect(page).to have_css('td:nth-of-type(3)', text: 'Deposited')
      end
      work = collection.works[2]
      row = all_trs.find { |tr| tr.has_css?('td:nth-of-type(1)', text: work.title) }
      within(row) do
        expect(page).to have_css('td:nth-of-type(3)', text: 'Saving')
        expect(page).to have_css('td:nth-of-type(5)', exact_text: '')
      end
    end
  end
end
