# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Connect GitHub account' do
  let(:user) { create(:user) }

  before do
    create(:collection, depositors: [user], github_deposit_enabled: true)

    sign_in(user)
  end

  it 'allows a user to connect their GitHub account' do
    visit user_github_path

    expect(page).to have_css('h1', text: 'Connect your SDR account to GitHub')

    within('.breadcrumbs ol') do
      expect(page).to have_link('Dashboard', href: dashboard_path)
      expect(page).to have_css('.breadcrumb-item', text: 'GitHub integration')
    end

    expect(page).to have_link('Cancel', href: dashboard_path)
    expect(page).to have_button('Connect to GitHub')
  end

  context 'when user is previously connected to GitHub' do
    let(:user) { create(:user, github_connected_at: Time.zone.now) }

    it 'allows a user to reconnect their GitHub account' do
      visit user_github_path

      expect(page).to have_button('Reconnect to GitHub')
    end
  end
end
