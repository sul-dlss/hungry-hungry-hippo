# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create an article deposit' do
  let(:druid) { druid_fixture }
  let(:user) { create(:user) }

  let(:doi) { '10.1128/mbio.01735-25' }
  let(:not_found_doi) { '10.1234/doesnotexistoncrossref' }

  before do
    create(:collection, user:, title: collection_title_fixture, druid: collection_druid_fixture, depositors: [user],
                        article_deposit_enabled: true)

    allow(CrossrefService).to receive(:call).with(doi: not_found_doi).and_raise(CrossrefService::NotFound)
    allow(CrossrefService).to receive(:call).with(doi:).and_return({ title: title_fixture })

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
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(build(:first_accessioning_version_status))
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    allow(Sdr::Event).to receive(:list).and_return([])

    sign_in(user)
  end

  it 'creates and deposits an article', :dropzone do
    visit dashboard_path
    click_link_or_button('Deposit article by DOI')

    # Breadcrumb
    expect(page).to have_link('Dashboard', href: dashboard_path)
    expect(page).to have_link(collection_title_fixture, href: collection_path(collection_druid_fixture))
    expect(page).to have_css('.breadcrumb-item', text: 'Article deposit')

    expect(page).to have_css('h1', text: 'Article deposit')

    # Validate blank DOI submission
    click_link_or_button('Lookup')

    expect(page).to have_css('.invalid-feedback', text: "can't be blank")

    # Validate missing DOI submission
    fill_in 'DOI', with: not_found_doi
    click_link_or_button('Lookup')
    expect(page).to have_css('.invalid-feedback', text: 'not found')

    # Deposit without required fields
    fill_in 'DOI', with: doi
    click_link_or_button('Deposit')
    expect(page).to have_css('.invalid-feedback', text: 'must have at least one file')
    expect(page).to have_css('.invalid-feedback', text: 'lookup before saving or depositing')

    # Lookup
    click_link_or_button('Lookup')
    expect(page).to have_no_css('.invalid-feedback')
    expect(page).to have_content(title_fixture)

    # Adding a file
    find('.dropzone').drop('spec/fixtures/files/hippo.png')

    expect(page).to have_css('table#content-table td', text: 'hippo.png')

    # Deposit
    click_link_or_button('Deposit')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_css('.status', text: 'Depositing')
    expect(page).to have_css('.alert-success', text: 'Deposit successfully submitted')
    expect(page).to have_no_link('Edit or deposit')

    # Details
    within('#details-table') do
      expect(page).to have_css('td', text: 'A DOI will not be assigned.')
    end

    # Title
    within('#title-table') do
      expect(page).to have_css('td', text: title_fixture)
    end

    # Work types
    within('#work-type-table') do
      expect(page).to have_css('td', text: 'Text')
      expect(page).to have_css('td', text: 'Article')
    end

    # Access settings
    within('#access-table') do
      expect(page).to have_css('td', text: 'Immediately')
      expect(page).to have_css('td', text: 'Everyone')
    end

    expect(Sdr::Repository).to have_received(:accession)
  end
end
