# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notifies unsaved changes' do
  include WorkMappingFixtures

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

  context 'when the user uploads a file' do
    it 'asks user to confirm leaving page', :dropzone do
      visit new_work_path(collection_druid: collection.druid)

      expect(page).to have_css('h1', text: 'Untitled deposit')

      # Adding a file
      find('.dropzone').drop('spec/fixtures/files/hippo.png')
      expect(page).to have_css('td', text: 'hippo.png')

      dismiss_confirm 'Are you sure you want to leave this page?' do
        click_link_or_button('Dashboard')
      end
    end
  end

  context 'when the user hides a file' do
    let(:druid) { druid_fixture }
    let(:cocina_object) do
      dro_with_structural_and_metadata_fixture
    end
    let(:version_status) { build(:draft_version_status, version: cocina_object.version) }

    before do
      collection = create(:collection, druid: collection_druid_fixture)
      create(:work, druid:, user:, collection:)
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
      allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    end

    it 'asks user to confirm leaving page' do
      visit edit_work_path(druid)

      expect(page).to have_css('h1', text: 'My title')

      check('Hide this file')

      dismiss_confirm 'Are you sure you want to leave this page?' do
        click_link_or_button('Dashboard')
      end
    end
  end

  context 'when the user edits a description' do
    let(:druid) { druid_fixture }
    let(:cocina_object) do
      dro_with_structural_and_metadata_fixture
    end
    let(:version_status) { build(:draft_version_status, version: cocina_object.version) }

    before do
      collection = create(:collection, druid: collection_druid_fixture)
      create(:work, druid:, user:, collection:)
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
      allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    end

    it 'asks user to confirm leaving page' do
      visit edit_work_path(druid)

      expect(page).to have_css('h1', text: 'My title')

      click_on('Edit this file')

      fill_in('Description', with: 'My new description')
      click_link_or_button('Save')

      dismiss_confirm 'Are you sure you want to leave this page?' do
        click_link_or_button('Stanford Digital Repository')
      end
    end
  end

  context 'when the user deletes a file' do
    let(:druid) { druid_fixture }
    let(:cocina_object) do
      dro_with_structural_and_metadata_fixture
    end
    let(:version_status) { build(:draft_version_status, version: cocina_object.version) }

    before do
      collection = create(:collection, druid: collection_druid_fixture)
      create(:work, druid:, user:, collection:)
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
      allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    end

    it 'asks user to confirm leaving page' do
      visit edit_work_path(druid)

      expect(page).to have_css('h1', text: 'My title')

      click_on('Remove this file')

      dismiss_confirm 'Are you sure you want to leave this page?' do
        click_link_or_button('Stanford Digital Repository')
      end
    end
  end
end
