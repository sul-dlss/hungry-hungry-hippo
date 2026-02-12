# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Manage shares' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let(:changing_share_user) { create(:user, email_address: 'jane@stanford.edu', name: 'Jane Stanford') }
  let(:deleting_share_user) { create(:user, email_address: 'junior@stanford.edu', name: 'Leland Stanford Jr.') }
  let(:collection) { create(:collection, :with_druid, user:) }
  let!(:work) { create(:work, druid:, title: title_fixture, collection:, user:) }
  let(:cocina_object) { dro_with_metadata_fixture }
  let(:version_status) { build(:openable_version_status) }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)

    allow(Sdr::Event).to receive(:list).with(druid:).and_return([])

    allow(AccountService).to receive(:call)
      .with(id: 'dsj')
      .and_return(AccountService::Account.new(name: 'David Starr Jordan', sunetid: 'dsj'))

    sign_in(user)
  end

  context 'when there are existing shares' do
    before do
      create(:share, user: changing_share_user, work:)
      create(:share, user: deleting_share_user, work:, permission: Share::VIEW_EDIT_DEPOSIT_PERMISSION)
    end

    it 'manages shares' do
      visit work_path(druid)

      expect(page).to have_css('h1', text: work.title)

      expect(page).to have_text('Jane Stanford (jane), Leland Stanford Jr. (junior)')

      click_link_or_button('Manage sharing')

      expect(page).to have_css('h1', text: work.title)
      expect(page).to have_css('h2', text: 'Manage shares')

      # Breadcrumbs
      expect(page).to have_link('Dashboard', href: dashboard_path)
      expect(page).to have_link(collection.title, href: collection_path(collection))
      expect(page).to have_link(work.title, href: work_path(work))
      expect(page).to have_css('.breadcrumb-item', text: 'Manage sharing')

      form_instances = page.all('.form-instance')
      expect(form_instances.size).to eq(2)

      within(form_instances[0]) do
        expect(page).to have_css('span', text: 'Jane Stanford (jane)')
        expect(page).to have_field('Share permission', with: Share::VIEW_PERMISSION)
        expect(page).to have_css('section[aria-label="Set sharing permissions for Jane Stanford"]')
        select('View and edit', from: 'Share permission')
      end

      within(form_instances[1]) do
        expect(page).to have_css('span', text: 'Leland Stanford Jr. (junior)')
        expect(page).to have_field('Share permission', with: Share::VIEW_EDIT_DEPOSIT_PERMISSION)
        click_link_or_button('Clear')
      end

      dismiss_confirm 'Are you sure you want to leave this page?' do
        click_link_or_button('Dashboard')
      end

      fill_in('Enter list of Stanford email addresses', with: 'dsj')
      click_link_or_button('Add')

      expect(page).to have_css('span', text: 'David Starr Jordan (dsj)')

      click_link_or_button('Save')

      expect(page).to have_current_path(work_path(druid))

      expect(page).to have_text('David Starr Jordan (dsj), Jane Stanford (jane)')

      expect(Share.find_by(work:, user: changing_share_user).permission).to eq(Share::VIEW_EDIT_PERMISSION)
      expect(Share.exists?(work:, user: deleting_share_user)).to be false
      new_user = User.find_by!(email_address: 'dsj@stanford.edu', name: 'David Starr Jordan')
      expect(Share.exists?(work:, user: new_user, permission: Share::VIEW_PERMISSION)).to be true
    end
  end

  context 'when there are no shares' do
    it 'does not show any share sections' do
      visit work_path(druid)

      expect(page).to have_css('h1', text: work.title)

      click_link_or_button('Manage sharing')

      expect(page).to have_css('h1', text: work.title)
      expect(page).to have_css('h2', text: 'Manage shares')

      expect(page).to have_no_css('.form-instance')

      click_link_or_button('Save')

      expect(page).to have_current_path(work_path(druid))
    end
  end
end
