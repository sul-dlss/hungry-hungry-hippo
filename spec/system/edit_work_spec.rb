# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit a work' do
  # Using mapping fixtures because it provides a roundtrippable DRO.
  include WorkMappingFixtures

  include_context 'with FAST connection'

  let(:query) { 'First%20Keyword' }
  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let(:cocina_object) do
    dro_with_structural_and_metadata_fixture
  end
  let(:version_status) { build(:draft_version_status, version: cocina_object.version) }
  let(:updated_title) { 'My new title' }
  let(:updated_contributors) do
    [
      {
        'first_name' => 'Leland',
        'last_name' => 'Stanford Jr.'
      },
      {
        'organization_name' => 'Some other organization'
      }
    ]
  end
  let(:updated_abstract) { 'This is what my work is really about.' }
  let(:updated_keywords) { ['First Keyword'] }
  let(:updated_related_works) do
    [
      {
        'relationship' => 'references',
        'identifier' => 'https://purl.stanford.edu/fake'
      }
    ]
  end

  let(:collection) do
    create(:collection, :with_required_contact_email, user:, druid: collection_druid_fixture,
                                                      title: collection_title_fixture, release_duration: 'three_years')
  end
  let!(:work) { create(:work, druid:, user:, collection:) }

  before do
    # On the second call, this will return the cocina object submitted to update.
    # This will allow us to test the updated values.
    allow(Sdr::Repository).to receive(:find).with(druid:).and_invoke(
      ->(_arg) { cocina_object }, # show
      ->(_arg) { cocina_object }, # edit
      ->(_arg) { cocina_object }, # update
      ->(_arg) { cocina_object }, # DepositWorkJob
      ->(_arg) { @updated_cocina_object } # show after update
    )
    allow(Sdr::Repository).to receive(:find_latest_user_version).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    # It is already open.
    allow(Sdr::Repository).to receive(:open_if_needed) { |args| args[:cocina_object] }
    allow(Sdr::Repository).to receive(:update) do |args|
      @updated_cocina_object = args[:cocina_object]
    end
    allow(Sdr::Event).to receive(:list).and_return([])

    sign_in(user)
  end

  it 'edits a work' do
    visit edit_work_path(druid, tab: 'title')

    expect(page).to have_css('.breadcrumb-item', text: collection_title_fixture)
    expect(page).to have_link(collection_title_fixture, href: collection_path(collection_druid_fixture))
    expect(page).to have_css('.breadcrumb-item', text: title_fixture)
    expect(page).to have_css('h1', text: title_fixture)

    expect(page).to have_button('Save as draft')
    expect(page).to have_button('Next')
    expect(page).to have_button('Discard draft')

    expect(page).to have_css('.nav-link.active', text: 'Title')
    expect(page).to have_field('Title of deposit', with: title_fixture)

    fill_in('Title of deposit', with: updated_title)

    # Show user that the collection manager already gave them a contact email for free
    expect(page).to have_text('Contact email provided by collection manager')
    expect(page).to have_text(works_contact_email_fixture)

    # Testing validation
    find('.nav-link', text: 'Abstract and keywords').click
    fill_in('work_abstract', with: '')
    find('.nav-link', text: 'Deposit', exact_text: true).click
    click_link_or_button('Deposit', class: 'btn-primary')
    expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')

    expect(Ahoy::Event.where_event(Ahoy::Event::INVALID_WORK_SUBMITTED,
                                   errors: ['Work abstract: blank'],
                                   review: false, deposit: true, work_id: work.id).count).to eq(1)

    # Fill in in authors
    find('.nav-link', text: 'Contributors').click
    form_instances = all('.form-instance')
    expect(form_instances.count).to eq(4)
    within(form_instances[0]) do
      expect(page).to have_checked_field('Individual', with: 'person')
      expect(page).to have_select('Role', selected: 'Author')
      within('.orcid-section') do
        expect(page).to have_checked_field('Lookup using ORCID iD')
      end
      expect(page).to have_field('ORCID iD', with: '0001-0002-0003-0004')
      expect(page).to have_field('First name', with: 'Jane')
      expect(page).to have_field('Last name', with: 'Stanford')
      expect(page).to have_field('Institution', with: 'Stanford University')
      expect(page).to have_field('Department/Center', with: 'Department of History')
    end
    within(form_instances[2]) do
      expect(page).to have_checked_field('Organization', with: 'organization')
      expect(page).to have_select('Role', selected: 'Host institution')
      expect(page).to have_field('Organization name', with: 'Stanford University Libraries')
    end
    within(form_instances[3]) do
      expect(page).to have_checked_field('Organization', with: 'organization')
      expect(page).to have_select('Role', selected: 'Degree granting institution')
      within('.stanford-degree-granting-institution-section') do
        expect(page).to have_checked_field('Yes')
      end
      expect(page).to have_field('Department / Institute / Center', with: 'Department of Philosophy')
    end
    fill_in('work_contributors_attributes_0_first_name', with: updated_contributors.first['first_name'])
    fill_in('work_contributors_attributes_0_last_name', with: updated_contributors.first['last_name'])
    fill_in('work_contributors_attributes_1_organization_name', with: updated_contributors.last['organization_name'])

    # Filling in abstract
    find('.nav-link', text: 'Abstract').click
    fill_in('work_abstract', with: updated_abstract)
    fill_in('work_keywords_attributes_1_text', with: updated_keywords.first)

    # Filling in citation
    find('.nav-link', text: 'Citation for this deposit (optional)').click
    expect(page).to have_text('Citation for this deposit (optional)')
    expect(page).to have_field('Enter preferred citation', with: citation_fixture)

    # Then add a related work
    find('.nav-link', text: 'Related content (optional)').click
    click_link_or_button('+ Add another related work')
    within_fieldset('Related works') do
      within('div[data-index="2"]') do
        fill_in('Full link for a related work (e.g., DOI, arXiv, PMID, PURL, or other URL). Include "https://".',
                with: updated_related_works.first['identifier'])
        select('My deposit references or cites', from: 'work_related_works_attributes_2_relationship')
      end
    end

    # Filling in access settings
    find('.nav-link', text: 'Access settings').click
    choose('Immediately')

    # Check What's changing
    find('.nav-link', text: 'Deposit', exact_text: true).click
    expect(page).to have_field('What\'s changing?', with: whats_changing_fixture)
    expect(page).to have_css('.alert', text: 'If you have modified the files, a new public version')
    click_link_or_button('Save as draft')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: updated_title)
    expect(page).to have_content(updated_abstract)
    expect(page).to have_content(updated_keywords.first)
    expect(page).to have_content('Leland Stanford Jr.')
    expect(page).to have_content('Some other organization')
    expect(page).to have_content('0001-0002-0003-0004')
    expect(page).to have_content(citation_fixture)
    expect(page).to have_content('Immediately')
    expect(page).to have_css('td', exact_text: 'Image')
    expect(page).to have_css('td', exact_text: 'Data, Photograph')
    expect(page).to have_css('.status', text: 'New version in draft')
    expect(page).to have_link('Edit or deposit', href: edit_work_path(druid))

    # Ahoy event is created
    expect(Ahoy::Event.where_event(Ahoy::Event::WORK_UPDATED, work_id: work.id, deposit: false,
                                                              review: false).count).to eq(1)
  end

  context 'when rejected' do
    before do
      work.request_review!
      work.reject_with_reason!(reason: 'Try harder.')
    end

    it 'shows a work with rejected alert' do
      visit edit_work_path(druid)

      within('.alert') do
        expect(page).to have_text('The reviewer for this collection has returned the deposit')
        expect(page).to have_css('blockquote', text: 'Try harder.')
      end
    end
  end

  context 'when openable (not a draft)' do
    let(:version_status) { build(:openable_version_status, version: cocina_object.version) }

    it 'has a whats changing value' do
      visit edit_work_path(druid)

      expect(page).to have_css('h1', text: title_fixture)

      # Check What's changing
      find('.nav-link', text: 'Deposit', exact_text: true).click
      expect(page).to have_field('What\'s changing?', with: '')
    end
  end

  context 'when openable first version' do
    let(:version_status) { build(:openable_version_status, version: 1) }

    it 'has a whats changing value' do
      visit edit_work_path(druid)

      expect(page).to have_css('h1', text: title_fixture)

      # Check What's changing
      find('.nav-link', text: 'Deposit', exact_text: true).click
      expect(page).to have_field('What\'s changing?', with: '')
    end
  end

  context 'when first version' do
    let(:version_status) { build(:first_draft_version_status) }

    it 'does not have a whats changing field' do
      visit edit_work_path(druid)

      expect(page).to have_css('h1', text: title_fixture)

      # Check What's changing
      find('.nav-link', text: 'Deposit', exact_text: true).click
      expect(page).to have_no_field('What\'s changing?')
    end
  end

  context 'when nothing changed and saving as draft' do
    before do
      allow(RoundtripSupport).to receive(:changed?).and_return(false)
    end

    it 'notifies user that nothing changed' do
      visit edit_work_path(druid)

      expect(page).to have_css('h1', text: title_fixture)
      click_link_or_button('Save as draft')

      expect(page).to have_css('.alert-warning', text: 'You have not made any changes to the form.')
      expect(page).to have_current_path(edit_work_path(druid))

      # Ahoy event is created
      expect(Ahoy::Event.where_event(Ahoy::Event::UNCHANGED_WORK_SUBMITTED, work_id: work.id, deposit: false,
                                                                            review: false).count).to eq(1)
    end
  end

  context 'when something changed, not providing whats changing, and saving as draft' do
    let(:version_status) { build(:openable_version_status, version: cocina_object.version, version_description: nil) }

    before do
      allow(RoundtripSupport).to receive(:changed?).and_return(true)
    end

    it 'notifies user the user that whats changing is required' do
      visit edit_work_path(druid)

      expect(page).to have_css('h1', text: title_fixture)

      find('.nav-link', text: 'Title').click
      expect(page).to have_css('.nav-link.active', text: 'Title')
      expect(page).to have_field('Title of deposit', with: title_fixture)

      fill_in('Title of deposit', with: updated_title)

      click_link_or_button('Save as draft')

      expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')
    end
  end

  context 'when nothing changed and depositing' do
    let(:version_status) { build(:openable_version_status, version: cocina_object.version) }

    before do
      allow(RoundtripSupport).to receive(:changed?).and_return(false)
    end

    it 'notifies user that nothing changed' do
      visit edit_work_path(druid)

      expect(page).to have_css('h1', text: title_fixture)

      find('.nav-link', text: 'Deposit', exact_text: true).click
      find('.btn-primary', text: 'Deposit', exact_text: true).click

      expect(page).to have_current_path(edit_work_path(druid))
      expect(page).to have_css('.alert-warning', text: 'You have not made any changes to the form.')
      expect(page).to have_no_text('Required fields have not been filled out.')
      expect(page).to have_css('.nav-link.active', text: 'Deposit', exact_text: true)

      # Ahoy event is created
      expect(Ahoy::Event.where_event(Ahoy::Event::UNCHANGED_WORK_SUBMITTED, work_id: work.id, deposit: true,
                                                                            review: false).count).to eq(1)
    end
  end

  context 'when changed and saving as draft' do
    before do
      allow(RoundtripSupport).to receive(:changed?).and_return(true)
    end

    it 'performs deposit' do
      visit edit_work_path(druid)

      expect(page).to have_css('h1', text: title_fixture)
      click_link_or_button('Save as draft')

      expect(page).to have_no_css('.alert-warning')
      expect(page).to have_current_path(work_path(druid))
    end
  end

  context 'when nothing changed, not open, and depositing' do
    let(:version_status) { build(:openable_version_status, version: cocina_object.version) }

    before do
      allow(RoundtripSupport).to receive(:changed?).and_return(false)
    end

    it 'notifies user that nothing changed' do
      visit edit_work_path(druid)

      expect(page).to have_css('h1', text: title_fixture)

      find('.nav-link', text: 'Deposit', exact_text: true).click
      fill_in('What\'s changing?', with: 'Nothing')
      click_link_or_button('Deposit', class: 'btn-primary')

      expect(page).to have_css('.alert-warning', text: 'You have not made any changes to the form.')
      expect(page).to have_current_path(edit_work_path(druid))
    end
  end

  context 'when nothing changed, open, and depositing' do
    let(:version_status) { build(:draft_version_status, version: cocina_object.version) }

    before do
      allow(RoundtripSupport).to receive(:changed?).and_return(false)
      allow(Sdr::Repository).to receive(:accession)
    end

    it 'performs deposit' do
      visit edit_work_path(druid)

      expect(page).to have_css('h1', text: title_fixture)

      find('.nav-link', text: 'Deposit', exact_text: true).click
      fill_in('What\'s changing?', with: 'Nothing')
      click_link_or_button('Deposit', class: 'btn-primary')

      expect(page).to have_no_css('.alert-warning')
      expect(page).to have_current_path(work_path(druid))
    end
  end

  context 'when adding a file' do
    let(:content) { work.content.last }

    it 'renders the file with the new file badge' do
      visit edit_work_path(druid)

      expect(page).to have_css('h1', text: title_fixture)

      find('.nav-link', text: 'Manage files').click
      expect(content.content_files.size).to eq 1
      expect(page).to have_text('my_file.txt') # filename in object

      # Adding a file
      find('.dropzone').drop('spec/fixtures/files/hippo.png')

      expect(page).to have_css('table#content-table td', text: 'hippo.png')
      expect(page).to have_css('span.badge', text: 'New')
    end
  end

  context 'with file search' do
    let(:content) { work.content.last }

    context 'when the file does not have enough objects to show a search box' do
      before do # ensure this is more than the number of files in the test object
        allow(Settings.search).to receive(:file_search_box_min).and_return(50)
      end

      it 'does not show a search box' do
        visit edit_work_path(druid)

        expect(page).to have_css('h1', text: title_fixture)

        find('.nav-link', text: 'Manage files').click
        expect(content.content_files.size).to eq 1
        expect(page).to have_text('my_file.txt') # filename in object
        expect(page).to have_no_css('#content-files-search') # no search box for files with only single file
      end
    end

    context 'when the file has enough objects to show a search box' do
      before do # always show the search box for this test
        allow(Settings.search).to receive(:file_search_box_min).and_return(0)
      end

      it 'shows search box and allows searching by filename' do
        visit edit_work_path(druid)

        expect(page).to have_css('h1', text: title_fixture)

        find('.nav-link', text: 'Manage files').click
        expect(page).to have_css('#content-files-search') # show search box for files because we changed setting
        expect(page).to have_text('my_file.txt') # filename in object
        expect(content.content_files.size).to eq 1

        # add a file
        find('.dropzone').drop('spec/fixtures/files/hippo.png')
        expect(content.content_files.size).to eq 2
        expect(page).to have_text('hippo.png')

        # search for the first file, which will hide the display of the second file
        within('div#content-files') do
          fill_in('content-files-search', with: 'my_file')
          click_link_or_button 'Search'
        end
        expect(page).to have_no_text('hippo.png')

        # search for bogus, which will hide the display of both files and show a message
        within('div#content-files') do
          fill_in('content-files-search', with: 'bogus')
          click_link_or_button 'Search'
        end
        expect(page).to have_no_text('hippo.png')
        expect(page).to have_no_text('my_file.txt')
        expect(page).to have_text('There are no results matching "bogus".')

        # clear search, showing both results again
        within('div#content-files') do
          fill_in('content-files-search', with: '')
          click_link_or_button 'Search'
        end
        expect(page).to have_text('hippo.png')
        expect(page).to have_text('my_file.txt')
      end
    end
  end
end
