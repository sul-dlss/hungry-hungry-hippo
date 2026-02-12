# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a Github repository and work deposit' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }

  let(:version_status) { build(:first_draft_version_status) }
  let(:work_version_status) { build(:draft_version_status) }

  before do
    allow(GithubService).to receive(:repository?).with('sul-dlss/happy-happy-hippo').and_return(false)
    allow(GithubService).to receive(:repository?).with('sul-dlss/hungry-hungry-hippo').and_return(true)
    allow(GithubService).to receive(:repository).with('sul-dlss/hungry-hungry-hippo').and_return(
      GithubService::Repository.new(id: 881_494_248, name: 'sul-dlss/hungry-hungry-hippo',
                                    url: 'https://github.com/sul-dlss/hungry-hungry-hippo',
                                    description: 'Self-Deposit for the Stanford Digital Repository (SDR)')
    )
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

    # Stubbing out for edit form
    allow(Sdr::Repository).to receive(:find).with(druid:).and_invoke(->(_arg) { @registered_cocina_object })
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status, work_version_status)
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    allow(Sdr::Event).to receive(:list).and_return([])

    create(:collection, user:, title: collection_title_fixture, druid: collection_druid_fixture, depositors: [user],
                        github_deposit_enabled: true)

    sign_in(user)
  end

  it 'creates a Github repository' do
    visit dashboard_path
    click_link_or_button('Select a GitHub repository')

    # Breadcrumbs
    expect(page).to have_link('Dashboard', href: dashboard_path)
    expect(page).to have_link(collection_title_fixture, href: collection_path(collection_druid_fixture))
    expect(page).to have_css('.breadcrumb-item', text: 'Select GitHub repository to deposit')

    expect(page).to have_css('h1', text: 'Select GitHub repository to deposit')

    expect(page).to have_link('Cancel')

    # Enter an invalid repository name
    fill_in('GitHub repository URL or owner/name', with: 'sul-dlss/happy-happy-hippo')
    click_link_or_button('Next')

    expect(page).to have_field('GitHub repository URL or owner/name', class: 'is-invalid')
    expect(page).to have_css('.invalid-feedback', text: 'is not a valid GitHub repository')

    # Enter a valid repository name
    fill_in('GitHub repository URL or owner/name', with: 'sul-dlss/hungry-hungry-hippo')
    click_link_or_button('Next')

    # Waiting page may be too fast to catch so not testing.
    # On edit form
    expect(page).to have_css('.breadcrumb-item', text: 'sul-dlss/hungry-hungry-hippo')

    expect(page).to have_css('h1', text: 'sul-dlss/hungry-hungry-hippo')

    # Manage files tab is not displayed
    expect(page).to have_no_link('Manage files')

    # Title is pre-populated
    find('.nav-link', text: 'Title and contact').click
    expect(page).to have_field('Title of deposit', with: 'sul-dlss/hungry-hungry-hippo')
    fill_in('Contact email', with: contact_emails_fixture.first['email'])

    # Add a contributor
    find('.nav-link', text: 'Authors / Contributors').click
    select('Creator', from: 'Role')
    within('.orcid-section') do
      find('label', text: 'Enter name manually').click
    end
    fill_in('First name', with: 'Jane')
    fill_in('Last name', with: 'Stanford')

    # Abstract is pre-populated
    find('.nav-link', text: 'Abstract and keywords').click
    expect(page).to have_field('Abstract', with: 'Self-Deposit for the Stanford Digital Repository (SDR)')
    fill_in('Keywords (one per box)', with: keywords_fixture.first['text'])

    # Work type is pre-populated
    find('.nav-link', text: 'Type of deposit').click
    expect(page).to have_checked_field('Software/Code')

    # DOI tab is not displayed
    expect(page).to have_no_link('DOI')

    # Access settings tab is not displayed
    expect(page).to have_no_link('Access settings')

    # Dates tab is not displayed
    expect(page).to have_no_link('Dates (optional)')

    # Related work is pre-populated
    find('.nav-link', text: 'Related content (optional)').click
    within('#related_content-pane .form-instance:first-of-type') do
      expect(page).to have_checked_field('Full link for a related work')
      expect(page).to have_field('Full link for a related work',
                                 with: 'https://github.com/sul-dlss/hungry-hungry-hippo', type: 'text')
      expect(page).to have_field('How is your deposit related to this work?',
                                 with: 'is derived from')
    end

    # Clicking on Next to go to the citation tab
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Citation for this deposit (optional)')

    # Clicking on Next to go to Deposit
    click_link_or_button('Next')
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Deposit', class: 'btn-primary')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: 'sul-dlss/hungry-hungry-hippo')
    expect(page).to have_css('.status', text: 'Depositing')
    expect(page).to have_css('.alert-success', text: 'Work successfully deposited')
    expect(page).to have_no_link('Edit or deposit')

    # Ahoy events are created
    work = Work.find_by(druid:)
    expect(work).to be_present
    expect(Ahoy::Event.where_event(Ahoy::Event::WORK_CREATED, work_id: work.id, deposit: false,
                                                              review: false).count).to eq(1)
  end
end
