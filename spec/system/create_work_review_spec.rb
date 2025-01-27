# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a work that requires review' do
  include_context 'with FAST connection'

  let(:query) { 'Biology' }
  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let(:version_status) do
    VersionStatus.new(status:
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, accessioning?: true,
                                                                         openable?: false, version: 1))
  end

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
    allow(Sdr::Repository).to receive(:accession)

    # Stubbing out for show page
    allow(Sdr::Repository).to receive(:find).with(druid:).and_invoke(->(_arg) { @registered_cocina_object })
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    create(:collection, :with_review_workflow, user:, druid: collection_druid_fixture, managers: [user])
    sign_in(user)
  end

  it 'creates and deposits a work' do
    visit root_path
    click_link_or_button('Deposit to this collection')

    expect(page).to have_css('h1', text: 'Untitled deposit')

    # Adding a file
    find('.dropzone').drop('spec/fixtures/files/hippo.png')

    expect(page).to have_css('table#content-table td', text: 'hippo.png')

    # Filling in title
    find('.nav-link', text: 'Title & contact').click
    fill_in('work_title', with: title_fixture)
    fill_in('Contact email', with: contact_emails_fixture.first['email'])

    # Click Next to go to authors tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Authors')

    # Enter an authors
    select('Creator', from: 'work_authors_attributes_0_person_role')
    fill_in('First name', with: 'Jane')
    fill_in('Last name', with: 'Stanford')

    # Click Next to go to abstract tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Abstract')

    # Filling in abstract & keywords
    fill_in('work_abstract', with: abstract_fixture)
    fill_in('Keywords (one per box)', with: keywords_fixture.first['text'])

    # Click Next to go to work type tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Type of deposit')

    # Selecting work type
    choose('Text')
    check('Thesis')

    # Clicking on Next to go to Deposit
    find('.nav-link', text: 'Deposit').click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Submit for review')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_css('.status', text: 'Pending review')
    expect(page).to have_no_link('Edit or deposit')
  end
end
