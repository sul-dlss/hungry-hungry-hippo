# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a work deposit' do
  include_context 'with FAST connection'
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }

  let(:query) { 'Biology' } # Used in stubbing out FAST connection

  before do
    allow(Sdr::Repository).to receive(:accession)

    create(:collection, user:, title: collection_title_fixture, druid: collection_druid_fixture, managers: [user],
                        custom_rights_statement_option: 'depositor_selects', doi_option: 'depositor_selects',
                        license_option: 'depositor_selects', license: 'https://www.apache.org/licenses/LICENSE-2.0')
    sign_in(user)
  end

  context 'when creating a new work' do
    let(:version_status) { build(:first_accessioning_version_status) }

    before do
      # Stubbing out for Deposit Job
      allow(Sdr::Repository).to receive(:register) do |args|
        cocina_params = args[:cocina_object].to_h
        cocina_params[:externalIdentifier] = druid
        cocina_params[:description][:purl] = Sdr::Purl.from_druid(druid:)
        cocina_params[:structural] = { isMemberOf: [collection_druid_fixture] }
        cocina_params[:administrative] = { hasAdminPolicy: Settings.apo }
        cocina_object = Cocina::Models.build(cocina_params)
        @registered_cocina_object = Cocina::Models.with_metadata(cocina_object, 'abc123')
      end

      # Stubbing out for show page
      allow(Sdr::Repository).to receive(:find).with(druid:).and_invoke(->(_arg) { @registered_cocina_object })
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
      allow(Sdr::Event).to receive(:list).and_return([])
    end

    it 'creates and deposits a work', :dropzone do
      visit dashboard_path
      click_link_or_button('Deposit to this collection')

      # Breadcrumb
      expect(page).to have_link('Dashboard', href: dashboard_path)
      expect(page).to have_link(collection_title_fixture, href: collection_path(collection_druid_fixture))
      expect(page).to have_css('.breadcrumb-item', text: 'Untitled deposit')

      expect(page).to have_css('h1', text: 'Untitled deposit')

      # Testing tabs
      # Manage files tab is active, abstract is not
      expect(page).to have_css('.nav-link.active', text: 'Manage files')
      expect(page).to have_css('.nav-link:not(.active)', text: 'Abstract')
      # Manage files pane with form field is visible, abstract is not
      expect(page).to have_css('h2', text: 'Manage files')
      expect(page).to have_css('.dropzone', text: 'Select files to upload')
      expect(page).to have_no_text('Describe your deposit')

      # Footer buttons
      expect(page).to have_button('Save as draft')
      expect(page).to have_button('Next')
      expect(page).to have_no_button('Previous')
      expect(page).to have_link('Cancel')

      # Testing previous / next
      click_link_or_button('Next')
      expect(page).to have_css('.nav-link.active', text: 'Title and contact')
      expect(page).to have_button('Next')
      expect(page).to have_button('Previous')
      click_link_or_button('Previous')
      expect(page).to have_css('.nav-link.active', text: 'Manage files')

      # Adding a file
      find('.dropzone').drop('spec/fixtures/files/hippo.png')

      expect(page).to have_css('table#content-table td', text: 'hippo.png')

      # Filling in title
      find('.nav-link', text: 'Title and contact').click
      fill_in('work_title', with: title_fixture)

      expect(page).to have_no_text('Contact email provided by collection manager')
      expect(page).to have_field('Contact email', with: user.email_address)
      click_link_or_button('Clear')
      expect(page).to have_field('Contact email', with: '')
      fill_in('Contact email', with: contact_emails_fixture.first['email'])

      # Click Next to go to contributors tab
      click_link_or_button('Next')
      expect(page).to have_css('.nav-link.active', text: 'Contributors')
      expect(page).to have_css('.h4', text: 'Contributors')

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

      # Click Next to go to abstract tab
      click_link_or_button('Next')
      expect(page).to have_css('.nav-link.active', text: 'Abstract')
      expect(page).to have_text('Abstract')

      # Filling in Abstract and keywords
      fill_in('work_abstract', with: abstract_fixture)
      expect(page).to have_text('Keywords')
      fill_in('Keywords (one per box)', with: keywords_fixture.first['text'])
      # Wait for autocomplete to load. FAST is stubbed out.
      expect(page).to have_css('li.list-group-item', text: 'Tearooms')

      # Go to work type tab
      # In test, Next button isn't working perhaps due to keywords autocomplete causing problem.
      find('.nav-link', text: 'Type of deposit').click
      expect(page).to have_css('.nav-link.active', text: 'Type of deposit')
      expect(page).to have_text('What type of content are you depositing?')

      choose('Text')
      check('Thesis')
      click_link_or_button('See more subtype options')
      expect(page).to have_field('3D model', type: 'checkbox', with: '3D model')
      # Type does not appear under more options
      expect(page).to have_no_field('Text', type: 'checkbox', with: 'Text')
      check('3D model')

      # Click Next to go to DOI tab
      click_link_or_button('Next')
      expect(page).to have_css('.nav-link.active', text: 'DOI')
      expect(page).to have_link('What is a DOI?')
      expect(page).to have_text('Do you want a DOI assigned to this work?')
      choose('No')

      # Clicking on Next to go to access settings tab
      click_link_or_button('Next')
      expect(page).to have_css('.nav-link.active', text: 'Access settings')
      expect(page).to have_css('label', text: 'Release date')
      choose('On this date')
      fill_in 'Release date', with: (Time.zone.today + 1.day).strftime('%m/%d/%Y')

      expect(page).to have_css('label', text: 'Individual file visibility')

      # Clicking on Next to go to license tab
      click_link_or_button('Next')
      expect(page).to have_css('.nav-link.active', text: 'License and additional terms of use')

      # Selecting license
      expect(page).to have_select('License', selected: 'Apache-2.0')
      select('CC-BY-4.0 Attribution International', from: 'work_license')

      # Entering additional terms of use
      fill_in('Additional terms of use (optional)', with: custom_rights_statement_fixture)

      # Clicking on Next to go to dates tab
      click_link_or_button('Next')
      expect(page).to have_css('.nav-link.active', text: 'Dates (optional)')
      expect(page).to have_text('Enter dates related to your deposit (optional)')

      # Filling in dates
      within_fieldset('publication_date') do
        fill_in('Year', with: '2024')
        select('June', from: 'Month')
        select('10', from: 'Day')
      end

      within_fieldset('creation_date') do
        fill_in('Year', with: '2023')
        select('May', from: 'Month')
      end

      # Clicking on Next to go to related content tab
      click_link_or_button('Next')
      expect(page).to have_css('.nav-link.active', text: 'Related content (optional)')
      expect(page).to have_css('.h4', text: 'Related content (optional)')

      # Filling in related works
      expect(page).to have_text('Related works')
      expect(page).to have_field('Link for a related work (e.g., DOI, arXiv, PMID, PURL, or other URL)',
                                 type: 'radio',
                                 checked: true)
      expect(page).to have_field('Enter full citation for related work', disabled: true)
      choose('Enter full citation for related work')
      expect(page).to have_field('Enter full citation for related work')
      expect(page).to have_field('Link for a related work (e.g., DOI, arXiv, PMID, PURL, or other URL)', disabled: true)
      choose('Link for a related work (e.g., DOI, arXiv, PMID, PURL, or other URL)')
      fill_in('Link for a related work (e.g., DOI, arXiv, PMID, PURL, or other URL)',
              with: related_works_fixture.second['identifier'])
      select('My deposit consists of parts, one of which is', from: 'How is your deposit related to this work?')

      # Filling in related links
      expect(page).to have_text('Related links')
      fill_in('Link text', with: related_links_fixture.first['text'])
      fill_in('URL', with: related_links_fixture.first['url'])

      # Clicking on Next to go to the citation tab
      click_link_or_button('Next')
      expect(page).to have_css('.nav-link.active', text: 'Citation for this deposit (optional)')

      # Switched to manage files tab
      find('.nav-link', text: 'Manage files').click
      expect(page).to have_css('.nav-link.active', text: 'Manage files')

      # Return
      find('.nav-link', text: 'Access settings').click
      expect(page).to have_css('.nav-link.active', text: 'Access settings')

      expect(page).to have_css('label', text: 'Download access')
      select('Everyone', from: 'work_access')

      # Clicking on Next to go to Deposit
      5.times { click_link_or_button('Next') }
      expect(page).to have_css('.nav-link.active', text: 'Deposit')

      expect(page).to have_no_text('If you have modified the files, a new public version')
      expect(page).to have_no_text('What\'s changing?')

      expect(page).to have_text('You have accepted the Terms of Deposit')
      expect(page).to have_no_text('I agree to the SDR Terms of Deposit')

      # Footer buttons
      expect(page).to have_button('Save as draft')
      expect(page).to have_button('Previous')
      expect(page).to have_no_button('Next')
      expect(page).to have_link('Cancel')

      click_link_or_button('Deposit', class: 'btn-primary')

      # Waiting page may be too fast to catch so not testing.
      # On show page
      expect(page).to have_css('h1', text: title_fixture)
      expect(page).to have_css('.status', text: 'Depositing')
      expect(page).to have_css('.alert-success', text: 'Work successfully deposited')
      expect(page).to have_no_link('Edit or deposit')

      # Contributors
      within('#contributors-table') do
        expect(page).to have_css('td', text: 'Jane Stanford')
        expect(page).to have_css('td', text: 'Stanford University')
      end

      # Has work types and subtypes
      expect(page).to have_text('Text')
      expect(page).to have_text('Thesis')
      expect(page).to have_text('3D model')

      # Ahoy event is created
      work = Work.find_by(druid:)
      expect(work).to be_present
      expect(Ahoy::Event.where_event(Ahoy::Event::WORK_CREATED, work_id: work.id, deposit: true,
                                                                review: false).count).to eq(1)
    end
  end

  context 'when updating an existing work' do
    let(:draft_version_status) { build(:draft_version_status) }

    let(:cocina_object) { dro_with_structural_and_metadata_fixture }
    let(:druid) { cocina_object.externalIdentifier }

    let!(:work) { create(:work, druid:, user:) }

    before do
      # Stubbing out for Deposit Job
      @updated_cocina_object = nil
      allow(Sdr::Repository).to receive(:update) do |args|
        @updated_cocina_object = args[:cocina_object]
      end

      # Stubbing out for show page
      allow(Sdr::Repository).to receive(:find).with(druid:)
                                              .and_invoke(
                                                ->(_arg) { cocina_object }, # show
                                                ->(_arg) { cocina_object }, # edit
                                                ->(_arg) { cocina_object }, # DepositWorkJob
                                                ->(_arg) { @updated_cocina_object } # show after deposit
                                              )
      allow(Sdr::Repository).to receive(:status).with(druid:)
                                                .and_return(draft_version_status)
      allow(Sdr::Event).to receive(:list).and_return([])
    end

    it 'updates and deposits a work' do
      visit work_path(druid)

      expect(page).to have_css('h1', text: title_fixture)
      click_link_or_button('Edit or deposit')

      expect(page).to have_css('.nav-link.active', text: 'Manage files')

      find('.nav-link', text: 'Title and contact').click
      fill_in('work_title', with: 'My new title')

      find('.nav-link', text: 'Deposit', exact_text: true).click

      fill_in('What\'s changing?', with: 'I am updating the title.')

      click_link_or_button('Deposit', class: 'btn-primary')

      # Waiting page may be too fast to catch so not testing.
      # On show page
      expect(page).to have_css('h1', text: 'My new title')

      # Ahoy events are created
      expect(Ahoy::Event.where_event(Ahoy::Event::WORK_UPDATED, work_id: work.id, deposit: true,
                                                                review: false).count).to eq(1)
    end
  end
end
