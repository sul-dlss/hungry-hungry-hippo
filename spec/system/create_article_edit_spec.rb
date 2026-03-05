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
      contributors_attributes: [{ first_name: 'A.', last_name: 'User' }],
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
    allow(Sdr::Repository).to receive(:check_lock)
    allow(Sdr::Repository).to receive(:find_latest_user_version).and_return(@registered_cocina_object)
    allow(Sdr::Repository).to receive(:update) do |args|
      @updated_cocina_object = args[:cocina_object]
    end
    allow(Sdr::Repository).to receive(:accession)
    allow(Sdr::Event).to receive(:list).and_return([])

    sign_in(user)
  end

  it 'creates an article and opens for edit', :dropzone do
    visit dashboard_path
    click_link_or_button(I18n.t('collections.buttons.labels.deposit_article'))

    # Adding a file
    find('.dropzone').drop('spec/fixtures/files/hippo.png')
    expect(page).to have_css('table#content-table td', text: 'hippo.png')

    # Setting version description
    select('Author accepted version', from: 'Which version are you depositing?')

    fill_in 'identifier_field', with: doi
    click_link_or_button('Look up')

    # Deposit
    click_link_or_button('Edit before deposit')

    # Waiting page may be too fast to catch so not testing.
    # On edit page
    expect(page).to have_css('h1', text: title_fixture)

    expect(page).to have_button('Save as draft')
    expect(page).to have_button('Next')
    expect(page).to have_button('Discard draft')

    # Adding a file
    find('.dropzone').drop('spec/fixtures/files/hippo.png')
    expect(page).to have_css('table#content-table td', text: 'hippo.png')

    find('.nav-link', text: with_required_tab_mark('Title and contact')).click
    expect(page).to have_field('Title of deposit', with: title_fixture)
    expect(page).to have_css('legend label', exact_text: 'Contact emails')

    find('.nav-link', exact_text: 'Abstract and keywords').click
    expect(page).to have_css('label', exact_text: 'Abstract')
    expect(page).to have_css('legend label', exact_text: 'Keywords')

    find('.nav-link', text: with_required_tab_mark('Type of deposit')).click
    expect(page).to have_field('Text', checked: true)
    expect(page).to have_field('Article', checked: true)
    expect(page).to have_field('Which version are you depositing?', with: 'Author accepted version')

    find('.nav-link', exact_text: 'Related content').click
    within('.form-instance:first-of-type') do
      expect(page).to have_field('Full link for a related work', checked: true)
      expect(page).to have_field('Full link for a related work', type: 'text', with: "https://doi.org/#{doi}")
      expect(page)
        .to have_select('How is your deposit related to this work?',
                        selected: "The version of record / publisher's version of my deposit is this related work")
    end

    # DOI tab should not be present since DOI will not be assigned
    expect(page).to have_no_css('.nav-link', text: 'DOI')

    # Deposit after editing
    find('.nav-link', text: with_required_tab_mark('Deposit')).click
    click_link_or_button('Deposit', class: 'btn-primary')

    # Waiting page may be too fast to catch so not testing.
    # On edit page
    expect(page).to have_css('h1', text: title_fixture)

    # Details
    within('#details-table') do
      expect(page).to have_css('td', text: 'A DOI will not be assigned.')
    end

    # Ahoy events created
    work = Work.find_by(druid:)
    expect(work).to be_present
    completed_events = Ahoy::Event.where_event(Ahoy::Event::ARTICLE_FORM_COMPLETED, work_id: work.id)
    expect(completed_events.count).to eq(1)
    visit_id = completed_events.first.visit_id
    expect(Ahoy::Event.where_event(Ahoy::Event::ARTICLE_FORM_STARTED).where(visit_id:).count).to eq(1)
    # article NOT created
    expect(Ahoy::Event.where_event(Ahoy::Event::ARTICLE_CREATED, work_id: work.id, deposit: true).count).to eq(0)
  end
end
