# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show home' do
  include ActionView::Helpers::SanitizeHelper
  before do
    sign_in(create(:user))
  end

  it 'shows the home page' do
    visit root_path

    expect(page).to have_content('Create or manage your deposits')
    expect(page).to have_link('Enter here', href: dashboard_path)
    expect(page).to have_content(strip_links(I18n.t('banner.home_html')))
    expect(page).to have_content('Sign up for our newsletter')
    expect(page).to have_css('.quote-card', text: 'I am definitely hearing more')
    expect(page).to have_css('.quote-card', count: 5)

    # Dropdown menu
    expect(page).to have_link('Dashboard', href: dashboard_path, visible: :hidden)
    expect(page).to have_link('Logout', href: logout_path, visible: :hidden)

    # Click link to test ahoy events
    click_link_or_button 'Help'
    expect(Ahoy::Event.where_event('$click', href: 'https://sdr.library.stanford.edu/documentation').count).to eq(1)
  end
end
