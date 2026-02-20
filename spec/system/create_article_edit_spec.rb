# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create an article then edit before deposit' do
  # include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }

  let(:doi) { '10.1128/mbio.01735-25' }

  let(:crossref_result) do
    {
      title: title_fixture,
      related_works_attributes: [{
        relationship: 'is version of record',
        identifier: "https://doi.org/#{doi}"
      }]
    }
  end

  before do
    create(:collection, user:, title: collection_title_fixture, druid: collection_druid_fixture, depositors: [user],
                        article_deposit_enabled: true)

    allow(CrossrefService).to receive(:call).with(doi:).and_return(crossref_result)

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

    # Stubbing out for edit page
    allow(Sdr::Repository).to receive(:find).with(druid:).and_invoke(->(_arg) { @registered_cocina_object })
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(build(:first_draft_version_status))
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)

    sign_in(user)
  end

  it 'creates and an article and opens for edit', :dropzone do
    visit dashboard_path
    click_link_or_button('Deposit article by DOI')

    # Adding a file
    find('.dropzone').drop('spec/fixtures/files/hippo.png')
    expect(page).to have_css('table#content-table td', text: 'hippo.png')

    fill_in 'DOI', with: doi
    click_link_or_button('Look up')

    # Deposit
    click_link_or_button('Edit before deposit')

    # Waiting page may be too fast to catch so not testing.
    # On edit page
    expect(page).to have_css('h1', text: title_fixture)

    expect(page).to have_button('Save as draft')
    expect(page).to have_button('Next')
    expect(page).to have_button('Discard draft')

    find('.nav-link', text: 'Title and contact').click
    expect(page).to have_field('Title of deposit', with: title_fixture)

    find('.nav-link', text: 'Type of deposit').click
    expect(page).to have_field('Text', checked: true)
    expect(page).to have_field('Article', checked: true)

    find('.nav-link', text: 'Access settings').click
    expect(page).to have_field('Immediately', checked: true)
    expect(page).to have_select('work_access', selected: 'Everyone')

    find('.nav-link', text: 'Related content').click
    within('.form-instance:first-of-type') do
      expect(page).to have_field('Full link for a related work', checked: true)
      expect(page).to have_field('Full link for a related work', type: 'text', with: "https://doi.org/#{doi}")
      expect(page)
        .to have_select('How is your deposit related to this work?',
                        selected: "The version of record / publisher's version of my deposit is this related work")
    end

    # DOI tab should not be present since DOI will not be assigned
    expect(page).to have_no_css('.nav-link', text: 'DOI')
  end
end
