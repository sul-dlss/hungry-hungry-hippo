# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show a work', :rack_test do
  let(:druid) { druid_fixture }
  let(:collection) { create(:collection) }
  let(:work) { create(:work, druid: druid, title: title_fixture, collection:) }
  let(:cocina_object) { build(:dro, title: work.title, id: druid) }
  let(:version_status) do
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, version: 2,
                                                                         openable?: true, accessioning?: false)
  end

  before do
    allow(Sdr::Repository).to receive(:find).with(druid: druid).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid: druid).and_return(version_status)

    sign_in(create(:user))
  end

  it 'creates a work draft' do
    visit work_path(druid)

    expect(page).to have_css('h1', text: work.title)
    expect(page).to have_css('.status', text: 'Deposited')
    expect(page).to have_link('Edit or deposit', href: edit_work_path(druid))

    # Title table
    within('table#title-table') do
      expect(page).to have_css('caption', text: 'Title')
      expect(page).to have_css('tr', text: 'Title')
      expect(page).to have_css('td', text: work.title)
    end
  end
end
