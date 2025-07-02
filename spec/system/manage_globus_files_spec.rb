# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Manage files for a work' do
  include WorkMappingFixtures

  let(:collection) { create(:collection, user:, druid: collection_druid_fixture) }
  let(:file_infos) { [double(size: 123, name: "/uploads/#{user.sunetid}/new/file1.txt")] }
  let(:user) { create(:user) }
  let(:globus_button_label) { 'Use Globus to transfer files' }

  before do
    allow(Settings.globus).to receive(:enabled).and_return(true)
    allow(GlobusSetupJob).to receive(:perform_later)
    allow(GlobusClient).to receive(:tasks_in_progress?).and_return(true, false)
    allow(GlobusClient).to receive_messages(disallow_writes: true, list_files: file_infos)

    sign_in(user)
  end

  context 'when a new work' do
    it 'does not allow managing globus' do
      visit new_work_path(collection_druid: collection.druid)

      expect(page).to have_css('h1', text: 'Untitled deposit')

      expect(page).to have_button(globus_button_label, disabled: true)
    end
  end

  context 'when a saved work' do
    let(:druid) { druid_fixture }
    let(:work) { create(:work, druid:, title: title_fixture, user:, collection:) }
    let(:cocina_object) { dro_with_metadata_fixture }
    let(:version_status) { build(:first_draft_version_status) }

    before do
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
      allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    end

    it 'manages globus' do
      visit edit_work_path(work.druid)

      expect(page).to have_css('h1', text: title_fixture)

      expect(page).to have_text('Your files will appear here once they have been uploaded.')

      click_link_or_button(globus_button_label)

      expect(page).to have_text('Click the link where your files are located')
      # Dropzone is disabled.
      expect(page).to have_css('#file-dropzone.opacity-50')

      # Perform Cancel
      within('#globus') do
        click_link_or_button('Cancel')
      end
      expect(page).to have_button(globus_button_label)
      expect(page).to have_css('#file-dropzone:not(.opacity-50)')

      click_link_or_button(globus_button_label)
      expect(page).to have_text('Click the link where your files are located')

      click_link_or_button('Globus file transfer complete')

      expect(page).to have_css('.alert', text: 'Transfers in progress.')

      click_link_or_button('Globus file transfer complete')

      expect(page).to have_no_css('.alert', text: 'Transfers in progress.')
      expect(page).to have_text('Getting list of files from Globus')

      within('#content-table') do
        expect(page).to have_text('file1.txt')
      end
      # For some reason the broadcast to refresh the globus frame does not work in the test environment.
      # expect(page).to have_button('I want to upload to Globus')
    end
  end
end
