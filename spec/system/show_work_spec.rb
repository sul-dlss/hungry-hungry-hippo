# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show a work', :rack_test do
  let(:druid) { druid_fixture }
  let!(:work) { create(:work, druid: druid, title: title_fixture) }
  let(:cocina_object) { build(:dro, title: work.title, id: druid) }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid: druid).and_return(cocina_object)

    sign_in(create(:user))
  end

  it 'creates a work draft' do
    visit work_path(druid)

    expect(page).to have_css('h1', text: work.title)

    # Title table
    within('table#title-table') do
      expect(page).to have_css('caption', text: 'Title')
      expect(page).to have_css('tr', text: 'Title')
      expect(page).to have_css('td', text: work.title)
    end
  end
end
