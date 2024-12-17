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
  let(:version_status) do
    VersionStatus.new(status:
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true, openable?: false,
                                                                         discardable?: true,
                                                                         version: cocina_object.version))
  end
  let(:updated_title) { 'My new title' }
  let(:updated_authors) do
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
  let(:updated_related_links) do
    [
      {
        'text' => 'My new link',
        'url' => 'https://new.stanford.edu/'
      }
    ]
  end
  let(:updated_related_works) do
    [
      {
        'relationship' => 'references',
        'identifier' => 'https://purl.stanford.edu/fake'
      }
    ]
  end

  before do
    # On the second call, this will return the cocina object submitted to update.
    # This will allow us to test the updated values.
    allow(Sdr::Repository).to receive(:find).with(druid:).and_invoke(->(_arg) { cocina_object }, lambda { |_arg|
      @updated_cocina_object
    })
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    # It is already open.
    allow(Sdr::Repository).to receive(:open_if_needed) { |args| args[:cocina_object] }
    allow(Sdr::Repository).to receive(:update) do |args|
      @updated_cocina_object = args[:cocina_object]
    end
    collection = create(:collection, user:, druid: collection_druid_fixture, title: collection_title_fixture)
    create(:work, druid:, user:, collection:)

    sign_in(user)
  end

  it 'edits a work' do
    visit edit_work_path(druid)

    expect(page).to have_css('.breadcrumb-item', text: collection_title_fixture)
    expect(page).to have_link(collection_title_fixture, href: collection_path(druid: collection_druid_fixture))
    expect(page).to have_css('.breadcrumb-item', text: title_fixture)
    expect(page).to have_css('h1', text: title_fixture)

    find('.nav-link', text: 'Title').click
    expect(page).to have_field('Title of deposit', with: title_fixture)

    fill_in('Title of deposit', with: updated_title)

    # Testing validation
    find('.nav-link', text: 'Abstract & keywords').click
    fill_in('work_abstract', with: '')
    find('.nav-link', text: 'Deposit').click
    click_link_or_button('Deposit')
    expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')

    # Fill in in authors
    find('.nav-link', text: 'Authors').click
    fill_in('work_authors_attributes_0_first_name', with: updated_authors.first['first_name'])
    fill_in('work_authors_attributes_0_last_name', with: updated_authors.first['last_name'])
    fill_in('work_authors_attributes_1_organization_name', with: updated_authors.last['organization_name'])

    # Filling in abstract
    find('.nav-link', text: 'Abstract').click
    fill_in('work_abstract', with: updated_abstract)
    fill_in('work_keywords_attributes_1_text', with: updated_keywords.first)

    # Filling in citation
    find('.nav-link', text: 'Citation for this deposit (optional)').click
    expect(page).to have_text('Citation for this deposit')
    expect(page).to have_field('Select citation', disabled: false)
    expect(page).to have_field('Select citation', with: citation_fixture)

    # Filling in related content, first related links
    find('.nav-link', text: 'Related content (optional)').click
    fill_in('Link text', with: 'delete')
    fill_in('URL', with: 'me')
    # Test adding a new nested field
    click_link_or_button('+ Add another related link')
    fill_in('work_related_links_attributes_1_text', with: updated_related_links.first['text'])
    fill_in('work_related_links_attributes_1_url', with: updated_related_links.first['url'])
    # Test removing a nested field
    within_fieldset('Related links') do
      within('div[data-index="0"]') do
        find('button[data-action="click->nested-form#delete"]').click
      end
    end
    # Then add a related work
    click_link_or_button('+ Add another related work')
    within_fieldset('Related works') do
      within('div[data-index="2"]') do
        fill_in('Link for a related work (e.g., DOI, arXiv, PMID, PURL, or other URL)',
                with: updated_related_works.first['identifier'])
        select('It references or cites', from: 'work_related_works_attributes_2_relationship')
      end
    end

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
    expect(page).to have_link(updated_related_links.first['text'], href: updated_related_links.first['url'])
    expect(page).to have_content('https://purl.stanford.edu/fake (references)')
    expect(page).to have_css('.status', text: 'New version in draft')
    expect(page).to have_link('Edit or deposit', href: edit_work_path(druid))
  end
end
