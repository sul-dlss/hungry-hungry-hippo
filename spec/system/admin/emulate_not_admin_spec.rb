# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Emulate not being an admin' do
  before do
    sign_in(create(:user, name: 'Fred Kroll'), groups: ['dlss:hydrus-app-administrators'])
  end

  it 'searches for a user and shows information' do
    visit admin_dashboard_path

    expect(page).to have_css('h1', text: 'Admin dashboard')
    expect(page).to have_text('Logged in: Fred Kroll (Admin)')

    click_link_or_button('Admin functions')
    click_link_or_button('Emulate being not an admin')

    expect(page).to have_css('h1', text: 'Emulate being not an admin')

    click_link_or_button('Submit')

    # Back on dashboard
    expect(page).to have_current_path(dashboard_path)
    expect(page).to have_text('Logged in: Fred Kroll')
    expect(page).to have_no_text('Logged in: Fred Kroll (Admin)')
  end
end
