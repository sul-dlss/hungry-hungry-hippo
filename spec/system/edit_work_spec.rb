# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit a work' do
  # Using mapping fixtures because it provides a roundtrippable DRO.
  include MappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }

  let(:cocina_object) do
    dro_with_metadata_fixture
  end

  let(:updated_cocina_object) do
    cocina_object.new(
      description: cocina_object.description.new(
        title: CocinaDescriptionSupport.title(title: updated_title),
        note: [CocinaDescriptionSupport.note(type: 'abstract', value: updated_abstract)]
      )
    )
  end

  let(:version_status) do
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true, openable?: false,
                                                                         version: cocina_object.version)
  end

  let(:updated_title) { 'My new title' }
  let(:updated_abstract) { 'This is what my work is really about.' }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object, updated_cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    # It is already open.
    allow(Sdr::Repository).to receive(:open_if_needed) { |args| args[:cocina_object] }
    allow(Sdr::Repository).to receive(:update)
    create(:work, druid: druid, user:)

    sign_in(user)
  end

  it 'edits a work' do
    visit edit_work_path(druid)

    expect(page).to have_css('h1', text: title_fixture)

    expect(page).to have_field('Title of deposit', with: title_fixture)

    fill_in('Title of deposit', with: updated_title)

    # Filling in abstract
    find('.nav-link', text: 'Abstract').click
    fill_in('work_abstract', with: abstract_fixture)

    click_link_or_button('Save as draft')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: updated_title)
    expect(page).to have_css('.status', text: 'New version in draft')
    expect(page).to have_link('Edit or deposit', href: edit_work_path(druid))
  end
end
