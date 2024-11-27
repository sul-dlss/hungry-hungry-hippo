# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a collection draft' do
  let(:druid) { collection_druid_fixture }
  let(:user) { create(:user) }

  let(:cocina_object) do
    cocina_object = build(:collection, title: collection_title_fixture, id: druid)
    Cocina::Models.with_metadata(cocina_object, 'abc123')
  end

  let(:version_status) do
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true, version: 1,
                                                                         openable?: false)
  end

  before do
    # Stubbing out for Deposit Job
    allow(Sdr::Repository).to receive(:register) do |args|
      cocina_params = args[:cocina_object].to_h
      cocina_params[:externalIdentifier] = druid
      cocina_params[:description][:purl] = Sdr::Purl.from_druid(druid:)
      cocina_object = Cocina::Models.build(cocina_params)
      Cocina::Models.with_metadata(cocina_object, 'abc123')
    end
    allow(Sdr::Repository).to receive(:accession)
    # Stubbing out for show page
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)

    sign_in(user)
  end

  it 'creates a work' do
    visit root_path
    click_link_or_button('Create a new collection')

    expect(page).to have_css('h1', text: 'Untitled collection')

    # Title is required.
    find('.nav-link', text: 'Title').click
    click_link_or_button('Save as draft')

    # Validation fails for title.
    expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')
    expect(page).to have_css('input.is-invalid#collection_title') # rubocop:disable Capybara/SpecificMatcher

    # Filling in title
    fill_in('collection_title', with: collection_title_fixture)

    # This should work now.
    click_link_or_button('Save as draft')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: collection_title_fixture)
    expect(page).to have_css('.status', text: 'Draft - Not deposited')
    expect(page).to have_link('Edit or deposit', href: edit_collection_path(druid))
  end
end
