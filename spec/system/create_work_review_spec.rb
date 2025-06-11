# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a work that requires review' do
  include_context 'with FAST connection'

  let(:query) { 'Biology' }
  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
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
    allow(Sdr::Repository).to receive(:accession)

    # Stubbing out for show page
    allow(Sdr::Repository).to receive(:find).with(druid:).and_invoke(->(_arg) { @registered_cocina_object })
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)

    allow(Settings.notifications).to receive(:enabled).and_return(true)
    allow(Sdr::Event).to receive(:create)
    allow(Sdr::Event).to receive(:list).and_return([])

    create(:collection, :with_review_workflow, user:, druid: collection_druid_fixture, depositors: [user])

    sign_in(user)
  end

  it 'creates and deposits a work' do
    visit dashboard_path
    click_link_or_button('Deposit to this collection')

    expect(page).to have_css('h1', text: 'Untitled deposit')

    # Adding a file
    find('.dropzone').drop('spec/fixtures/files/hippo.png')

    expect(page).to have_css('table#content-table td', text: 'hippo.png')

    # Filling in title
    find('.nav-link', text: 'Title and contact').click
    fill_in('work_title', with: title_fixture)
    fill_in('Contact email', with: contact_emails_fixture.first['email'])

    # Click Next to go to contributors tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Contributors')

    # Enter a contributor
    form_instances = all('.form-instance')
    within(form_instances.first) do
      select('Creator', from: 'Role')
      within('.orcid-section') do
        find('label', text: 'Enter name manually').click
      end
      fill_in('First name', with: 'Jane')
      fill_in('Last name', with: 'Stanford')
    end

    # Click Next to go to abstract tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Abstract')

    # Filling in Abstract and keywords
    fill_in('work_abstract', with: abstract_fixture)
    fill_in('Keywords (one per box)', with: keywords_fixture.first['text'])

    # Go to work type tab
    # In test, Next button isn't working perhaps due to keywords autocomplete causing problem.
    find('.nav-link', text: 'Type of deposit').click
    expect(page).to have_css('.nav-link.active', text: 'Type of deposit')

    # Selecting work type
    choose('Text')
    check('Thesis')

    # Clicking on Next to go to Deposit
    find('.nav-link', text: 'Deposit', exact_text: true).click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Submit for review')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_css('.status', text: 'Pending review')
    expect(page).to have_no_link('Edit or deposit')

    expect(Sdr::Event).to have_received(:create).with(druid:, type: 'h3_review_requested', data: { who: user.sunetid })

    # Ahoy event is created
    work = Work.find_by(druid:)
    expect(work).to be_present
    expect(Ahoy::Event.where_event(Ahoy::Event::WORK_CREATED, work_id: work.id, deposit: false,
                                                              review: true).count).to eq(1)
  end
end
