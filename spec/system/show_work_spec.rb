# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show a work' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let(:share_user) { create(:user) }
  let(:collection) { create(:collection, :with_druid, user:) }
  let!(:work) { create(:work, druid:, title: title_fixture, collection:, user:) }
  # Need multiple files to test pagination
  let(:cocina_object) do
    dro_with_metadata_fixture.new(structural: {
                                    contains: [
                                      {
                                        type: 'https://cocina.sul.stanford.edu/models/resources/file',
                                        externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74',
                                        label: 'My file1',
                                        version: 2,
                                        structural: {
                                          contains: [
                                            {
                                              type: 'https://cocina.sul.stanford.edu/models/file',
                                              externalIdentifier: 'https://cocina.sul.stanford.edu/file/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74/my_file1.text',
                                              label: 'My file1',
                                              filename: 'my_file1.txt',
                                              size: 204_615,
                                              version: 2,
                                              hasMimeType: 'text/plain',
                                              sdrGeneratedText: false,
                                              correctedForAccessibility: false,
                                              hasMessageDigests: [
                                                { type: 'md5', digest: '46b763ec34319caa5c1ed090aca46ef2' },
                                                { type: 'sha1', digest: 'd4f94915b4c6a3f652ee7de8aae9bcf2c37d93ea' }
                                              ],
                                              access: { view: 'world', download: 'world',
                                                        controlledDigitalLending: false },
                                              administrative: { publish: false, sdrPreserve: true, shelve: false }
                                            }
                                          ]
                                        }
                                      },
                                      {
                                        type: 'https://cocina.sul.stanford.edu/models/resources/file',
                                        externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/lb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74',
                                        label: 'My file2',
                                        version: 2,
                                        structural: {
                                          contains: [
                                            {
                                              type: 'https://cocina.sul.stanford.edu/models/file',
                                              externalIdentifier: 'https://cocina.sul.stanford.edu/file/lb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74/my_file2.text',
                                              label: 'My file2',
                                              filename: 'dir1/my_file2.txt',
                                              size: 204_615,
                                              version: 2,
                                              hasMimeType: 'text/plain',
                                              sdrGeneratedText: false,
                                              correctedForAccessibility: false,
                                              hasMessageDigests: [
                                                { type: 'md5', digest: '46b763ec34319caa5c1ed090aca46ef2' },
                                                { type: 'sha1', digest: 'd4f94915b4c6a3f652ee7de8aae9bcf2c37d93ea' }
                                              ],
                                              access: { view: 'world', download: 'world',
                                                        controlledDigitalLending: false },
                                              administrative: { publish: true, sdrPreserve: true, shelve: true }
                                            }
                                          ]
                                        }
                                      },
                                      {
                                        type: 'https://cocina.sul.stanford.edu/models/resources/file',
                                        externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/mb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74',
                                        label: 'My file3',
                                        version: 2,
                                        structural: {
                                          contains: [
                                            {
                                              type: 'https://cocina.sul.stanford.edu/models/file',
                                              externalIdentifier: 'https://cocina.sul.stanford.edu/file/mb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74/my_file2.text',
                                              label: 'My file3',
                                              filename: 'dir1/dir2/my_file3.txt',
                                              size: 204_615,
                                              version: 2,
                                              hasMimeType: 'text/plain',
                                              sdrGeneratedText: false,
                                              correctedForAccessibility: false,
                                              hasMessageDigests: [
                                                { type: 'md5', digest: '46b763ec34319caa5c1ed090aca46ef2' },
                                                { type: 'sha1', digest: 'd4f94915b4c6a3f652ee7de8aae9bcf2c37d93ea' }
                                              ],
                                              access: { view: 'world', download: 'world',
                                                        controlledDigitalLending: false },
                                              administrative: { publish: true, sdrPreserve: true, shelve: true }
                                            }
                                          ]
                                        }
                                      }
                                    ],
                                    isMemberOf: []
                                  })
  end
  let(:version_status) { build(:openable_version_status) }
  let(:contact_emails) { (contact_emails_fixture.pluck('email') + [works_contact_email_fixture]) }

  let(:events) do
    [Dor::Services::Client::Events::Event.new(event_type: 'version_close', timestamp: '2020-01-27T19:10:27.291Z',
                                              data: { 'who' => 'lstanfordjr', 'description' => 'Version 1 closed' })]
  end

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    # File doesn't matter; it just needs to exist.
    allow(StagingSupport).to receive(:staging_filepath).and_call_original
    allow(StagingSupport).to receive(:staging_filepath).with(druid: work.druid, filepath: 'my_file1.txt')
                                                       .and_return('spec/fixtures/files/hippo.txt')

    allow(Sdr::Event).to receive(:list).with(druid:).and_return(events)

    create(:share, user: share_user, work:)

    sign_in(user)
  end

  context 'without hierarchical display', :default_per_page2 do
    before do
      allow(Settings.file_upload).to receive(:hierarchical_files_limit).and_return(0)
    end

    it 'shows a work' do
      visit work_path(druid)

      # Breadcrumbs
      expect(page).to have_link('Dashboard', href: dashboard_path)
      expect(page).to have_link(collection.title, href: collection_path(collection))
      expect(page).to have_css('.breadcrumb-item', text: work.title)

      expect(page).to have_css('h1', text: work.title)
      expect(page).to have_css('.status', text: 'Deposited')
      expect(page).to have_link('Edit or deposit', href: edit_work_path(druid))
      expect(page).to have_no_css('.alert-success', text: 'Work successfully deposited')
      expect(page).to have_no_content('Admin functions')

      # Files table
      within('table#files-table') do
        expect(page).to have_css('caption', text: 'Files')
        expect(page).to have_link('Edit', href: edit_work_path(druid, tab: 'files'))
        expect(page).to have_css('th', text: 'File Name')
        expect(page).to have_css('th', text: 'Description')
        expect(page).to have_css('td', text: 'my_file1.txt')
        content_file = ContentFile.find_by(filepath: 'my_file1.txt')
        expect(page).to have_link('Download file', href: "/content_files/#{content_file.id}/download")
        expect(page).to have_css('td', text: 'My file1')
        expect(page).to have_css('td', text: 'dir1/my_file2.txt')
        expect(page).to have_no_css('td', text: 'dir1/dir2/my_file3.txt')
        expect(page).to have_css('td', text: 'No')
        expect(page).to have_css('td', text: 'Yes')
      end
      expect(page).to have_css('ul.pagination')
      click_link_or_button('Next')
      within('table#files-table') do
        expect(page).to have_css('td', text: 'dir1/dir2/my_file3.txt')
        expect(page).to have_no_css('td', text: 'my_file1.txt')
      end

      # Details table
      within('table#details-table') do
        expect(page).to have_css('caption', text: 'Details')
        expect(page).to have_css('tr', text: 'DOI')
        expect(page).to have_css('td', text: Doi.url(druid:))
        expect(page).to have_css('tr', text: 'Public webpage')
        expect(page).to have_css('td', text: Sdr::Purl.from_druid(druid:))
        expect(page).to have_css('tr', text: 'Collection')
        expect(page).to have_css('td', text: collection.title)
        expect(page).to have_css('tr', text: 'Depositor')
        expect(page).to have_css('td', text: user.name)
        expect(page).to have_css('tr', text: 'Shared with')
        expect(page).to have_css('td', text: share_user.name)
        expect(page).to have_css('a', text: 'Manage sharing') # .have_link_or_button wasn't working correctly.
        expect(page).to have_css('tr', text: 'Version')
        expect(page).to have_css('td', text: '1')
        expect(page).to have_css('tr', text: 'Total number of files')
        expect(page).to have_css('td', text: '3')
        expect(page).to have_css('tr', text: 'Size')
        expect(page).to have_css('td', text: '599 KB')
        expect(page).to have_css('tr', text: 'Deposit created')
        expect(page).to have_css('td', text: I18n.l(Time.zone.now, format: :long))
      end

      # Title table
      within('table#title-table') do
        expect(page).to have_css('caption', text: 'Title and contact')
        expect(page).to have_link('Edit', href: edit_work_path(druid, tab: 'title'))
        expect(page).to have_css('tr', text: 'Title')
        expect(page).to have_css('td', text: work.title)
        expect(page).to have_css('tr', text: 'Contact emails')
        expect(page).to have_css('td',
                                 text: contact_emails.join(', '))
      end

      # Contributors table
      within('table#contributors-table') do
        expect(page).to have_css('caption', text: 'Authors / Contributors')
        expect(page).to have_link('Edit', href: edit_work_path(druid, tab: 'contributors'))
        expect(page).to have_css('th', text: 'Contributor')
        expect(page).to have_css('th', text: 'ORCID')
        expect(page).to have_css('th', text: 'Role')
        within('tbody tr:nth-of-type(1)') do
          expect(page).to have_css('td:nth-of-type(1)', text: 'Jane Stanford')
          expect(page).to have_css('td:nth-of-type(2)', text: 'https://orcid.org/0001-0002-0003-0004')
          expect(page).to have_css('td:nth-of-type(3)', text: 'Author')
        end
        within('tbody tr:nth-of-type(3)') do
          expect(page).to have_css('td:nth-of-type(1)', text: 'Department of Philosophy, Stanford University')
        end
      end

      # Description table
      within('table#description-table') do
        expect(page).to have_css('caption', text: 'Abstract and keywords')
        expect(page).to have_link('Edit', href: edit_work_path(druid, tab: 'abstract'))
        expect(page).to have_css('tr', text: 'Abstract')
        expect(page).to have_css('td', text: abstract_fixture)
        expect(page).to have_css('tr', text: 'Keywords')
        expect(page).to have_css('td', text: keywords_fixture.pluck(:text).join(', '))
      end

      # Work type table
      within('table#work-type-table') do
        expect(page).to have_css('caption', text: 'Type of deposit')
        expect(page).to have_link('Edit', href: edit_work_path(druid, tab: 'types'))
        expect(page).to have_css('tr', text: 'Deposit type')
        expect(page).to have_css('td', text: work_type_fixture)
        expect(page).to have_css('tr', text: 'Deposit subtypes')
        expect(page).to have_css('td', text: work_subtypes_fixture.join(', '))
      end

      # Dates table
      within('table#dates-table') do
        expect(page).to have_css('caption', text: 'Dates')
        expect(page).to have_link('Edit', href: edit_work_path(druid, tab: 'dates'))
        expect(page).to have_css('tr', text: 'Publication date')
        expect(page).to have_css('td', text: '2024-12')
        expect(page).to have_css('tr', text: 'Creation date')
        expect(page).to have_css('td', text: '2021-03-07 - 2022-04~')
      end

      # Preferred citation table
      within('table#citation-table') do
        expect(page).to have_css('caption', text: 'Citation')
        expect(page).to have_link('Edit', href: edit_work_path(druid, tab: 'citation'))
        expect(page).to have_css('tr', text: 'Preferred citation')
        expect(page).to have_css('td', text: citation_fixture)
      end

      # Related Content table
      within('table#related-content-table') do
        expect(page).to have_css('caption', text: 'Related content')
        expect(page).to have_css('tr', text: 'Related published work')
        expect(page).to have_css('td p', text: 'Here is a valid citation.')
        expect(page).to have_css('td p', text: 'Relationship: My deposit is one part of this related work')
        expect(page).to have_css('td p', text: 'doi:10.7710/2162-3309.1059')
      end

      # Access settings table
      within('table#access-table') do
        expect(page).to have_css('caption', text: 'Access settings')
        expect(page).to have_link('Edit', href: edit_work_path(druid, tab: 'access'))
        expect(page).to have_css('tr', text: 'Available')
        expect(page).to have_css('td', text: 'June 10, 2027')
        expect(page).to have_css('tr', text: 'Access')
        expect(page).to have_css('td', text: 'Stanford Community')
      end

      # License table
      within('table#license-table') do
        expect(page).to have_css('caption', text: 'License')
        expect(page).to have_link('Edit', href: edit_work_path(druid, tab: 'license'))
        expect(page).to have_css('tr', text: 'License')
        expect(page).to have_css('td', text: license_label_fixture)
        expect(page).to have_css('tr', text: 'Terms of use')
        expect(page).to have_css('td',
                                 text: custom_rights_statement_fixture)
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
        expect(page).to have_css('td', text: 'Version 1 closed')
      end
    end
  end

  context 'with hierarchical display' do
    it 'shows a work' do
      visit work_path(druid)

      expect(page).to have_css('h1', text: work.title)
      expect(page).to have_css('.status', text: 'Deposited')
      expect(page).to have_link('Edit or deposit', href: edit_work_path(druid))

      # Files table
      within('table#files-table') do
        expect(page).to have_css('caption', text: 'Files')
        expect(page).to have_link('Edit', href: edit_work_path(druid, tab: 'files'))
        expect(page).to have_css('th', text: 'File Name')
        expect(page).to have_css('th', text: 'Description')
        expect(page).to have_css('th', text: 'Hide')
        row1 = page.find('tbody tr:nth-child(1)')
        expect(row1).to have_css('td', text: 'my_file1.txt')
        content_file = ContentFile.find_by(filepath: 'my_file1.txt')
        expect(row1).to have_link('Download file', href: "/content_files/#{content_file.id}/download")
        expect(row1).to have_css('td', text: 'My file1')
        expect(row1).to have_css('td', text: 'Yes')
        row2 = page.find('tr:nth-child(2)')
        expect(row2).to have_css('td', text: 'dir1')
        row3 = page.find('tr:nth-child(3)')
        expect(row3).to have_css('td', text: 'my_file2.txt')
        row4 = page.find('tr:nth-child(4)')
        expect(row4).to have_css('td', text: 'dir2')
        row5 = page.find('tr:nth-child(5)')
        expect(row5).to have_css('td', text: 'my_file3.txt')
        row4.click
        expect(row5).not_to be_visible
        row4.click
        expect(row5).to be_visible
        row2.click
        expect(row3).not_to be_visible
        expect(row4).not_to be_visible
        expect(row5).not_to be_visible
      end
    end
  end

  context 'when rejected' do
    before do
      work.request_review!
      work.reject_with_reason!(reason: 'Try harder.')
    end

    it 'shows a work with rejected alert' do
      visit work_path(druid)

      within('.alert') do
        expect(page).to have_text('The reviewer for this collection has returned the deposit')
        expect(page).to have_css('blockquote', text: 'Try harder.')
      end
    end
  end

  context 'when not editable' do
    let(:version_status) { build(:accessioning_version_status) }

    it 'shows a work' do
      visit work_path(druid)

      expect(page).to have_css('h1', text: work.title)
      expect(page).to have_css('.status', text: 'Depositing')
      expect(page).to have_no_link('Edit or deposit')
      expect(page).to have_no_link('Edit')
    end
  end
end
