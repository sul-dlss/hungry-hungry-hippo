# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show recent activity for items' do
  let(:user) { create(:user) }
  let!(:work) { create(:work, :with_druid, user:, updated_at: 5.days.ago, collection:) }
  let(:collection) { create(:collection, :with_druid, user:, updated_at: 5.days.ago) }

  before do
    sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
  end

  it 'displays the works with recent activity' do
    visit admin_dashboard_path

    expect(page).to have_css('h1', text: 'Admin dashboard')

    click_link_or_button('Admin functions')
    click_link_or_button('Items recent activity')

    expect(page).to have_css('h1', text: 'Items recent activity')

    expect(page).to have_select('Days limit', selected: '7 days')

    within('#recent-activity-table') do
      within('thead') do
        expect(page).to have_css('tr', count: 1)
        first_row = page.find('tr:nth-of-type(1)')
        expect(first_row).to have_css('th:nth-of-type(1)', text: 'Items')
        expect(first_row).to have_css('th:nth-of-type(2)', text: 'Collection')
      end
      within('tbody') do
        expect(page).to have_css('tr', count: 1)
        first_row = page.find('tr:nth-of-type(1)')
        expect(first_row).to have_css('td:nth-of-type(1)', text: work.title)
        expect(first_row).to have_link(work.title, href: "/works/#{work.druid}")
        expect(first_row).to have_css('td:nth-of-type(2)', text: collection.title)
        expect(first_row).to have_link(collection.title, href: "/collections/#{collection.druid}")
      end
    end

    select('1 day', from: 'Days limit')
    expect(page).to have_table('recent-activity-table')
    expect(page).to have_css('tbody tr', count: 0)
    expect(page).to have_content('No items activity for time period selected.')
  end

  it 'displays the collections with recent activity' do
    visit admin_dashboard_path

    expect(page).to have_css('h1', text: 'Admin dashboard')

    click_link_or_button('Admin functions')
    click_link_or_button('Collections recent activity')

    expect(page).to have_css('h1', text: 'Collections recent activity')

    expect(page).to have_select('Days limit', selected: '7 days')

    within('#recent-activity-table') do
      within('thead') do
        expect(page).to have_css('tr', count: 1)
        first_row = page.find('tr:nth-of-type(1)')
        expect(first_row).to have_css('th:nth-of-type(1)', text: 'Collections')
      end
      within('tbody') do
        expect(page).to have_css('tr', count: 1)
        first_row = page.find('tr:nth-of-type(1)')
        expect(first_row).to have_css('td:nth-of-type(1)', text: collection.title)
        expect(first_row).to have_link(collection.title, href: "/collections/#{collection.druid}")
      end
    end

    select('1 day', from: 'Days limit')
    expect(page).to have_table('recent-activity-table')
    expect(page).to have_css('tbody tr', count: 0)
    expect(page).to have_content('No collections activity for time period selected.')
  end
end
