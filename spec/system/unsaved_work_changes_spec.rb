# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notifies unsaved changes' do
  let(:user) { create(:user) }
  let(:collection) { create(:collection, :with_druid, user:) }

  before do
    sign_in(user)
  end

  it 'asks user to confirm leaving page' do
    visit new_work_path(collection_druid: collection.druid)

    expect(page).to have_css('h1', text: 'Untitled deposit')

    find('.nav-link', text: 'Title and contact').click
    fill_in('Title', with: title_fixture)

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
