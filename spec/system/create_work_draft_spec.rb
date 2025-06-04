# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a work draft' do
  let(:druid) { druid_fixture }
  let(:user) { create(:user) }

  let(:version_status) { build(:first_draft_version_status) }

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
    allow(Sdr::Event).to receive(:list).and_return([])

    create(:collection, user:, title: collection_title_fixture, druid: collection_druid_fixture, managers: [user])

    sign_in(user)
  end

  it 'creates a work' do
    visit dashboard_path
    click_link_or_button('Deposit to this collection')

    # Breadcrumbs
    expect(page).to have_link('Dashboard', href: dashboard_path)
    expect(page).to have_link(collection_title_fixture, href: collection_path(collection_druid_fixture))
    expect(page).to have_css('.breadcrumb-item', text: 'Untitled deposit')

    expect(page).to have_css('h1', text: 'Untitled deposit')

    expect(page).to have_link('Cancel', href: dashboard_path)

    # Title is required.
    find('.nav-link', text: 'Title and contact').click
    click_link_or_button('Save as draft')

    # Validation fails for title.
    expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')
    expect(page).to have_field('work_title', class: 'is-invalid')

    # Filling in title
    fill_in('work_title', with: title_fixture)
    fill_in('Contact email', with: contact_emails_fixture.first['email'])

    # This should work now.
    click_link_or_button('Save as draft')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_css('.status', text: 'Draft - Not deposited')
    expect(page).to have_no_css('.alert-success', text: 'You have successfully submitted your work')
    expect(page).to have_link('Edit or deposit', href: edit_work_path(druid))
    expect(page).to have_no_css('#contributors-table td')
  end
end
