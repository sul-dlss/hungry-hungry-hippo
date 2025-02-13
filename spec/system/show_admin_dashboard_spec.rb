# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show admin dashboard', :rack_test do
  before do
    sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
  end

  it 'show dashboard' do
    visit dashboard_path

    click_link_or_button 'Admin'

    expect(page).to have_css('h1', text: 'Admin dashboard')
  end
end
