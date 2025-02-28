# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notifies unsaved changes' do
  let(:user) { create(:user) }

  before do
    sign_in(user, groups: ['dlss:hydrus-app-collection-creators'])
  end

  it 'asks user to confirm leaving page' do
    visit new_collection_path

    expect(page).to have_css('h1', text: 'Untitled collection')

    fill_in('Collection name', with: collection_title_fixture)

    dismiss_confirm 'Are you sure you want to leave this page?' do
      click_link_or_button('Dashboard')
    end

    dismiss_confirm 'Are you sure you want to leave this page?' do
      click_link_or_button('Cancel')
    end

    accept_confirm 'Are you sure you want to leave this page?' do
      click_link_or_button('Cancel')
    end

    expect(page).to have_current_path(dashboard_path)
  end
end
