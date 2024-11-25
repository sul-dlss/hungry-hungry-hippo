# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit a work' do
  # Using mapping fixtures because it provides a roundtrippable DRO.
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }

  let(:cocina_object) do
    dro_with_metadata_fixture
  end

  let(:updated_cocina_object) do
    cocina_object.new(
      description: cocina_object.description.new(
        title: CocinaDescriptionSupport.title(title: updated_title),
        note: [CocinaDescriptionSupport.note(type: 'abstract', value: updated_abstract)],
        relatedResource: CocinaDescriptionSupport.related_links(related_links: updated_related_links)
      )
    )
  end

  let(:version_status) do
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true, openable?: false,
                                                                         version: cocina_object.version)
  end

  let(:updated_title) { 'My new title' }
  let(:updated_abstract) { 'This is what my work is really about.' }
  let(:updated_related_links) do
    [
      {
        'text' => 'My new link',
        'url' => 'https://new.stanford.edu/'
      }
    ]
  end

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object, updated_cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    # It is already open.
    allow(Sdr::Repository).to receive(:open_if_needed) { |args| args[:cocina_object] }
    allow(Sdr::Repository).to receive(:update)
    create(:work, druid: druid, user:)

    sign_in(user)
  end

  it 'edits a work' do
    visit edit_work_path(druid)

    expect(page).to have_css('h1', text: title_fixture)

    find('.nav-link', text: 'Title').click
    expect(page).to have_field('Title of deposit', with: title_fixture)

    fill_in('Title of deposit', with: updated_title)

    # Testing validation
    find('.nav-link', text: 'Abstract').click
    fill_in('work_abstract', with: '')
    find('.nav-link', text: 'Deposit').click
    click_link_or_button('Deposit')
    expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')

    # Filling in abstract
    fill_in('work_abstract', with: updated_abstract)

    # Filling in related content
    find('.nav-link', text: 'Related content (optional)').click
    fill_in('Link text', with: 'delete')
    fill_in('URL', with: 'me')
    # Test adding a new nested field
    click_link_or_button('+ Add another related link')
    fill_in('work_related_links_attributes_1_text', with: updated_related_links.first['text'])
    fill_in('work_related_links_attributes_1_url', with: updated_related_links.first['url'])
    # Test removing a nested field
    within('div[data-index="0"]') do
      find('button[data-action="click->nested-form#delete"]').click
    end

    click_link_or_button('Save as draft')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: updated_title)
    expect(page).to have_content(updated_abstract)
    expect(page).to have_link(updated_related_links.first['text'], href: updated_related_links.first['url'])
    expect(page).to have_css('.status', text: 'New version in draft')
    expect(page).to have_link('Edit or deposit', href: edit_work_path(druid))
  end
end
