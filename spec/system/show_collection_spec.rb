# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show a collection' do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }
  let(:user) { collection.user }
  let!(:collection) do
    create(:collection, :with_review_workflow, :with_depositors, :with_managers, reviewers_count: 2, druid:,
                                                                                 title: collection_title_fixture)
  end
  let(:cocina_object) { collection_with_metadata_fixture }
  let(:version_status) do
    VersionStatus.new(status:
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, version: 2,
                                                                         openable?: true, accessioning?: false,
                                                                         discardable?: false))
  end

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)

    sign_in(user)
  end

  it 'shows a collection' do
    visit collection_path(druid)

    # Breadcrumb
    expect(page).to have_link('Dashboard', href: root_path)
    expect(page).to have_css('.breadcrumb-item', text: collection.title)

    expect(page).to have_css('h1', text: collection.title)
    expect(page).to have_css('.status', text: 'Deposited')
    expect(page).to have_link('Edit or deposit', href: edit_collection_path(druid))

    # Tabs
    expect(page).to have_css('.nav-link.active', text: 'Collection details')

    # Details table
    within('table#details-table') do
      expect(page).to have_css('caption', text: 'Details')
      expect(page).to have_css('tr', text: 'Title')
      expect(page).to have_css('td', text: collection.title)
      expect(page).to have_css('tr', text: 'Description')
      expect(page).to have_css('td', text: collection_description_fixture)
      expect(page).to have_css('tr', text: 'Contact emails')
      expect(page).to have_css('td', text: contact_emails_fixture.pluck(:email).join(', '))
    end

    # Related Content table
    within('table#related-content-table') do
      expect(page).to have_css('caption', text: 'Related content')
      expect(page).to have_css('tr', text: 'Related links')
      expect(page).to have_css('td', text: related_links_fixture.first['text'])
    end

    # Change tab
    click_link_or_button('Collection settings')
    expect(page).to have_css('.nav-link.active', text: 'Collection settings')

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
      expect(page).to have_css('tr', text: 'Default license (depositor selects)')
      expect(page).to have_css('td', text: 'Apache-2.0')
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
  end
end
