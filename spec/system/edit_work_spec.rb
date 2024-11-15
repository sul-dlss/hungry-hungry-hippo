# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit a work' do
  # Using mapping fixtures because it provides a roundtrippable DRO.
  include MappingFixtures

  let(:druid) { druid_fixture }

  let(:cocina_object) do
    dro_with_metadata_fixture
  end

  let(:version_status) do
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: true, openable?: false,
                                                                         version: cocina_object.version)
  end

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    create(:work, druid: druid)

    sign_in(create(:user))
  end

  it 'edits a work' do
    visit edit_work_path(druid)

    expect(page).to have_css('h1', text: title_fixture)

    expect(page).to have_field('Title of deposit', with: title_fixture)
  end
end
