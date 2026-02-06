# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Disconnect GitHub account' do
  let(:user) { create(:user, :connected_to_github) }

  before do
    sign_in(user)
  end

  it 'allows a user to disconnect their GitHub account' do
    visit user_github_path

    expect(page).to have_css('h1', text: 'Your GitHub account is connected')

    within('.breadcrumbs ol') do
      expect(page).to have_link('Dashboard', href: dashboard_path)
      expect(page).to have_css('.breadcrumb-item', text: 'GitHub integration')
    end

    expect(page).to have_link('Cancel', href: dashboard_path)
    expect(page).to have_button('Disconnect GitHub')
  end
end
