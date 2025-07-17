# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search for and show a user' do
  let(:user) { create(:user) }

  let!(:managed_collection) { create(:collection, :with_druid, managers: [user]) }
  let!(:reviewed_collection) { create(:collection, :with_druid, reviewers: [user]) }
  let!(:depositor_collection) { create(:collection, :with_druid, depositors: [user]) }
  let!(:all_roles_collection) do
    create(:collection, :with_druid, depositors: [user], managers: [user], reviewers: [user])
  end
  let!(:owned_collection) { create(:collection, :with_druid, user:) }
  let(:owned_work) { create(:work, :with_druid, user:) }

  before do
    allow(Sdr::Repository).to receive(:statuses).with(druids: [owned_work.druid])
                                                .and_return({ owned_work.druid => build(:version_status) })
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid: owned_work.druid).and_return(1)
    sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
  end

  it 'searches for a user and shows information' do
    visit admin_dashboard_path

    expect(page).to have_css('h1', text: 'Admin dashboard')

    fill_in('Search for user by SUNet', with: 'not_a_real_sunet_id')
    within('#user-search') do
      click_link_or_button('Search')
    end
    expect(page).to have_css('.invalid-feedback', text: 'not found')

    fill_in('Search for user by SUNet', with: user.sunetid)
    within('#user-search') do
      click_link_or_button('Search')
    end

    expect(page).to have_css('h1', text: user.name)

    within('#collection-access-table') do
      expect(page).to have_css('caption', text: 'Collections this user can access')
      within("tr#collection-access-table_collection_#{managed_collection.id}") do
        expect(page).to have_link(managed_collection.title)
        expect(page).to have_css('td', text: 'Manager')
      end
      within("tr#collection-access-table_collection_#{reviewed_collection.id}") do
        expect(page).to have_link(reviewed_collection.title)
        expect(page).to have_css('td', text: 'Reviewer')
      end
      within("tr#collection-access-table_collection_#{depositor_collection.id}") do
        expect(page).to have_link(depositor_collection.title)
        expect(page).to have_css('td', text: 'Depositor')
      end
      within("tr#collection-access-table_collection_#{all_roles_collection.id}") do
        expect(page).to have_link(all_roles_collection.title)
        expect(page).to have_css('td', text: 'Manager, Depositor, Reviewer')
      end
    end

    within('#collection-owned-table') do
      expect(page).to have_css('caption', text: 'Collections created by user')
      within("tr#collection-owned-table_collection_#{owned_collection.id}") do
        expect(page).to have_link(owned_collection.title)
      end
    end

    within('#work-owned-table') do
      expect(page).to have_css('caption', text: 'Works owned by user')
      within("tr#work-owned-table_work_#{owned_work.id}") do
        expect(page).to have_link(owned_work.title)
        expect(page).to have_link(owned_work.collection.title)
        expect(page).to have_css('td', text: 'Deposited')
      end
    end
  end
end
