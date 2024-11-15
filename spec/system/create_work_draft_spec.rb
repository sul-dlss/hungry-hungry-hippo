# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a work draft' do
  let(:druid) { druid_fixture }

  let(:cocina_object) do
    build(:dro, title: title_fixture, id: druid)
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
      cocina_params[:structural] = {}
      Cocina::Models.build(cocina_params)
    end
    allow(Sdr::Repository).to receive(:accession)
    # Stubbing out for show page
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)

    sign_in(create(:user))
  end

  it 'creates a work' do
    visit new_work_path

    expect(page).to have_css('h1', text: 'Untitled deposit')

    # This shouldn't work because title is required.
    click_link_or_button('Save as draft')

    # Filling in title
    fill_in('work_title', with: title_fixture)

    # This should work now.
    click_link_or_button('Save as draft')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_css('.status', text: 'Draft - Not deposited')
    expect(page).to have_link('Edit or deposit', href: edit_work_path(druid))
  end
end
