# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show a work' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let(:collection) { create(:collection, user:) }
  let!(:work) { create(:work, druid: druid, title: title_fixture, collection:, user:) }
  # Need multiple files to test pagination
  let(:cocina_object) do
    dro_with_metadata_fixture.new(structural: {
                                    contains: [
                                      {
                                        type: 'https://cocina.sul.stanford.edu/models/resources/file',
                                        externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74',
                                        label: 'My file',
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
                                              filename: 'my_file2.txt',
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
                                        label: 'My file2',
                                        version: 2,
                                        structural: {
                                          contains: [
                                            {
                                              type: 'https://cocina.sul.stanford.edu/models/file',
                                              externalIdentifier: 'https://cocina.sul.stanford.edu/file/mb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74/my_file2.text',
                                              label: 'My file3',
                                              filename: 'my_file3.txt',
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
  let(:version_status) do
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, version: 2,
                                                                         openable?: true, accessioning?: false)
  end

  before do
    allow(Sdr::Repository).to receive(:find).with(druid: druid).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid: druid).and_return(version_status)

    Kaminari.configure do |config|
      config.default_per_page = 2
    end

    sign_in(user)
  end

  it 'shows a work' do
    visit work_path(druid)

    expect(page).to have_css('h1', text: work.title)
    expect(page).to have_css('.status', text: 'Deposited')
    expect(page).to have_link('Edit or deposit', href: edit_work_path(druid))

    # Files table
    within('table#files-table') do
      expect(page).to have_css('caption', text: 'Files')
      expect(page).to have_css('th', text: 'Filename')
      expect(page).to have_css('th', text: 'Description')
      expect(page).to have_css('td', text: 'my_file1.txt')
      expect(page).to have_css('td', text: 'My file1')
      expect(page).to have_css('td', text: 'my_file2.txt')
      expect(page).to have_no_css('td', text: 'my_file3.txt')
      expect(page).to have_css('td', text: 'No')
      expect(page).to have_css('td', text: 'Yes')
    end
    expect(page).to have_css('ul.pagination')
    click_link_or_button('Next')
    within('table#files-table') do
      expect(page).to have_css('td', text: 'my_file3.txt')
      expect(page).to have_no_css('td', text: 'my_file1.txt')
    end

    # Details table
    within('table#details-table') do
      expect(page).to have_css('caption', text: 'Details')
      expect(page).to have_css('tr', text: 'Persistent Link')
      expect(page).to have_css('td', text: Sdr::Purl.from_druid(druid:))
      expect(page).to have_css('tr', text: 'Collection')
      expect(page).to have_css('td', text: collection.title)
      expect(page).to have_css('tr', text: 'Depositor')
      expect(page).to have_css('td', text: user.name)
      expect(page).to have_css('tr', text: 'Version details')
      expect(page).to have_css('td', text: '1')
      expect(page).to have_css('tr', text: 'Deposit created')
      expect(page).to have_css('td', text: I18n.l(Time.zone.now, format: :long))
    end

    # Title table
    within('table#title-table') do
      expect(page).to have_css('caption', text: 'Title and contact')
      expect(page).to have_css('tr', text: 'Title')
      expect(page).to have_css('td', text: work.title)
      expect(page).to have_css('tr', text: 'Contact emails')
      expect(page).to have_css('td', text: contact_emails_fixture.pluck(:email).join(', '))
    end

    # Description table
    within('table#description-table') do
      expect(page).to have_css('caption', text: 'Abstract and keywords')
      expect(page).to have_css('tr', text: 'Abstract')
      expect(page).to have_css('td', text: abstract_fixture)
      expect(page).to have_css('tr', text: 'Keywords')
      expect(page).to have_css('td', text: keywords_fixture.pluck(:text).join(', '))
    end

    # Work type table
    within('table#work-type-table') do
      expect(page).to have_css('caption', text: 'Type of deposit')
      expect(page).to have_css('tr', text: 'Deposit type')
      expect(page).to have_css('td', text: work_type_fixture)
      expect(page).to have_css('tr', text: 'Deposit subtypes')
      expect(page).to have_css('td', text: work_subtypes_fixture.join(', '))
    end

    # Related Content table
    within('table#related-content-table') do
      expect(page).to have_css('caption', text: 'Related content')
      expect(page).to have_css('tr', text: 'Related links')
      expect(page).to have_css('td', text: related_links_fixture.first['text'])
      expect(page).to have_css('tr', text: 'Related published work')
      expect(page).to have_css('td', text: 'Here is a valid citation. (part of)')
      expect(page).to have_css('td', text: 'doi:10.7710/2162-3309.1059 (has part)')
    end

    # License table
    within('table#license-table') do
      expect(page).to have_css('caption', text: 'License')
      expect(page).to have_css('tr', text: 'License')
      expect(page).to have_css('td', text: license_label_fixture)
      expect(page).to have_css('tr', text: 'Terms of use')
      expect(page).to have_css('td',
                               text: 'Content distributed via the Stanford Digital Repository may be subject to ' \
                                     'additional license and use restrictions applied by the depositor.')
    end

    # Dates table
    within('table#dates-table') do
      expect(page).to have_css('caption', text: 'Dates')
      expect(page).to have_css('tr', text: 'Publication date')
      expect(page).to have_css('td', text: '2024-12')
    end
  end
end
