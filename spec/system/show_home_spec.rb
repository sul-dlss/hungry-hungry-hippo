# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show home', :rack_test do
  before do
    sign_in(create(:user))
  end

  it 'shows the home page' do
    visit root_path

    expect(page).to have_content('Create or manage your deposits')
    expect(page).to have_link('Enter here', href: dashboard_path)
    expect(page).to have_content('Sign up for our newsletter')
    expect(page).to have_css('.quote-card', text: 'I am definitely hearing more')
    expect(page).to have_css('.quote-card', count: 5)
  end
end
