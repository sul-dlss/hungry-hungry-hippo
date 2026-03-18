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
    expect(page).to have_content(
      strip_tags(
        'This application will be down for maintenance starting Friday, March 20 after 3:00pm Pacific and will be available again on Monday, March 23. ' \
          'Depositing to the SDR will be unavailable during this time. If you have any questions, contact us at sdr-contact@lists.stanford.edu.'
      )
    )
    expect(page).to have_content('Sign up for our newsletter')
    expect(page).to have_css('.quote-card', text: 'I am definitely hearing more')
    expect(page).to have_css('.quote-card', count: 7)
    credit = page.find('.hero .position-absolute.bottom-0.start-0').text
    expect(HeroImagePresenter::IMAGES.map(&:last)).to include(credit)

    # Dropdown menu
    expect(page).to have_link('Dashboard', href: dashboard_path, visible: :hidden)
    expect(page).to have_link('Logout', href: logout_path, visible: :hidden)

    # Click link to test ahoy events
    click_link_or_button 'Help'
    expect(Ahoy::Event.where_event('$click', href: 'https://sdr.library.stanford.edu/documentation').count).to eq(1)
  end
end
