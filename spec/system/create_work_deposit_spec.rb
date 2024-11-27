# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a work deposit' do
  let(:druid) { druid_fixture }
  let(:user) { create(:user) }

  let(:version_status) do
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, accessioning?: true,
                                                                         openable?: false)
  end

  before do
    # Stubbing out for Deposit Job
    allow(Sdr::Repository).to receive(:register) do |args|
      cocina_params = args[:cocina_object].to_h
      cocina_params[:externalIdentifier] = druid
      cocina_params[:description][:purl] = Sdr::Purl.from_druid(druid:)
      cocina_params[:structural] = { isMemberOf: [collection_druid_fixture] }
      cocina_object = Cocina::Models.build(cocina_params)
      (@registered_cocina_object = Cocina::Models.with_metadata(cocina_object, 'abc123'))
    end
    allow(Sdr::Repository).to receive(:accession)

    # Stubbing out for show page
    allow(Sdr::Repository).to receive(:find).with(druid:).and_invoke(->(_arg) { @registered_cocina_object }) # rubocop:disable RSpec/InstanceVariable
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)

    create(:collection, user:, druid: collection_druid_fixture)

    sign_in(user)
  end

  it 'creates a work' do
    visit root_path
    click_link_or_button('Deposit to this collection')

    expect(page).to have_css('h1', text: 'Untitled deposit')

    # Testing tabs
    # Manage files tab is active, abstract is not
    expect(page).to have_css('.nav-link.active', text: 'Manage files')
    expect(page).to have_css('.nav-link:not(.active)', text: 'Abstract')
    # Manage files pane with form field is visible, abstract is not
    expect(page).to have_css('div.h4', text: 'Manage files')
    expect(page).to have_css('.dropzone', text: 'Select files to upload')
    expect(page).to have_no_text('Describe your deposit')

    # Adding a file
    # This doesn't work in Cyperful
    find('.dropzone').drop('spec/fixtures/files/hippo.png')

    expect(page).to have_css('table#content-table td', text: 'hippo.png')

    # Filling in title
    find('.nav-link', text: 'Title').click
    fill_in('work_title', with: title_fixture)

    # Click Next to go to abstract tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Abstract')
    expect(page).to have_text('Describe your deposit')

    # Filling in abstract
    fill_in('work_abstract', with: abstract_fixture)

    # Clicking on Next to go to related content tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Related content (optional)')
    expect(page).to have_text('Related links')

    # Filling in related links
    fill_in('Link text', with: related_links_fixture.first['text'])
    fill_in('URL', with: related_links_fixture.first['url'])

    # Clicking on Next to go to license tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'License')

    # Selecting license
    select('CC-BY-4.0 Attribution International', from: 'work_license')

    # Clicking on Next to go to Deposit
    click_link_or_button('Next')
    find('.nav-link', text: 'Deposit').click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Deposit')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_css('.status', text: 'Depositing')
    expect(page).to have_no_link('Edit or deposit')
  end
end
