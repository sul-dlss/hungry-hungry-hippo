# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show a work', :rack_test do
  let(:druid) { 'druid:bc123df4567' }

  before do
    sign_in(create(:user))
  end

  it 'creates a work draft' do
    visit work_path(druid)

    expect(page).to have_css('h1', text: 'My Title for druid:bc123df4567')

    # Title table
    within('table#title-table') do
      expect(page).to have_css('caption', text: 'Title')
      expect(page).to have_css('tr', text: 'Title')
      expect(page).to have_css('td', text: 'My Title for druid:bc123df4567')
    end
  end
end
