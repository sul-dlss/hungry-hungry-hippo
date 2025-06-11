# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delete a work' do
  include WorkMappingFixtures

  let(:cocina_object) { dro_with_metadata_fixture }
  let(:druid) { cocina_object.externalIdentifier }
  let(:version_status) { build(:openable_version_status) }
  let(:collection) { create(:collection, :with_druid) }
  let!(:work) { create(:work, druid:, title: title_fixture, collection:) }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    allow(Sdr::Repository).to receive(:open_if_needed) { |args| args[:cocina_object] }
    allow(Sdr::Event).to receive(:list).and_return([])

    sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
  end

  it 'deletes a work' do
    visit work_path(druid)

    expect(page).to have_css('h1', text: work.title)
    click_link_or_button('Admin functions')
    click_link_or_button('Delete')

    check('I confirm this item has been decommissioned in Argo and understand that this action cannot be undone.')
    click_link_or_button('Delete')

    expect(page).to have_css('h1', text: 'Dashboard')
    expect(page).to have_css('.alert', text: 'Work successfully deleted.')
    expect(Work.exists?(work.id)).to be false
    expect(page).to have_current_path(dashboard_path)
  end
end
