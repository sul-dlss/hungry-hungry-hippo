# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Manage files for a work' do
  let(:user) { create(:user) }
  let(:collection) { create(:collection, :with_druid, user:) }

  before do
    sign_in(user)
  end

  context 'when hierarchical display' do
    it 'creates a work' do
      visit new_work_path(collection_druid: collection.druid)

      expect(page).to have_css('h1', text: 'Untitled deposit')

      expect(page).to have_text('Your files will appear here once they have been uploaded.')

      # Add one file
      # Can't test folder upload, so no hierarchy.
      # This doesn't work in Cyperful
      find('.dropzone').drop('spec/fixtures/files/hippo.png')

      within('table#content-table') do
        expect(page).to have_css('td:nth-of-type(1)', text: 'hippo.png') # Filename
        expect(page).to have_css('td:nth-of-type(2)', text: '') # Label
      end

      # Add 2 more files
      find('.dropzone').drop('spec/fixtures/files/hippo.svg', 'spec/fixtures/files/hippo.txt')

      # Delete the first file
      within('table#content-table tbody tr:nth-of-type(1)') do
        expect(page).to have_css('td:nth-of-type(1)', text: 'hippo.png') # Filename
        find('a', text: 'Remove').click
      end

      expect(page).to have_no_css('table#content-table td', text: 'hippo.png')
      expect(page).to have_css('table#content-table td', text: 'hippo.svg')
      expect(page).to have_css('table#content-table td', text: 'hippo.txt')

      # Edit the description
      all('a', text: 'Add description').first.click
      fill_in('Description', with: 'This is a hippo.')
      click_link_or_button('Update')

      # The description is updated.
      expect(page).to have_css('table#content-table td', text: 'hippo.svg')
      expect(page).to have_css('table#content-table td', text: 'This is a hippo.')
      content_file = ContentFile.find_by(filepath: 'hippo.svg')
      expect(content_file.label).to eq('This is a hippo.')

      # Hide the file
      all('input[type=checkbox][name="content_file[hide]"]').first.check
      expect(page).to have_field('hide', checked: true)
      sleep 0.25 # Wait for the form to submit.
      expect(content_file.reload.hide).to be true
    end
  end

  context 'when non-hierarchical display' do
    before do
      allow(Settings.file_upload).to receive(:hierarchical_files_limit).and_return(0)
    end

    it 'creates a work' do
      visit new_work_path(collection_druid: collection.druid)

      expect(page).to have_css('h1', text: 'Untitled deposit')

      expect(page).to have_text('Your files will appear here once they have been uploaded.')

      # Add one file
      # This doesn't work in Cyperful
      find('.dropzone').drop('spec/fixtures/files/hippo.png')

      within('table#content-table') do
        expect(page).to have_css('td:nth-of-type(1)', text: 'hippo.png') # Filename
        expect(page).to have_css('td:nth-of-type(2)', text: '') # Label
      end
      expect(page).to have_no_css('ul.pagination')

      # Add 2 more files
      find('.dropzone').drop('spec/fixtures/files/hippo.svg', 'spec/fixtures/files/hippo.txt')

      # First 2 are listed on page.
      expect(page).to have_css('ul.pagination')
      expect(page).to have_css('table#content-table td', text: 'hippo.png')
      expect(page).to have_css('table#content-table td', text: 'hippo.svg')
      expect(page).to have_no_css('table#content-table td', text: 'hippo.txt')

      # Go to the next page
      all('a', text: 'Next', class: 'page-link').first.click

      # Third is listed on page.
      expect(page).to have_no_css('table#content-table td', text: 'hippo.png')
      expect(page).to have_no_css('table#content-table td', text: 'hippo.svg')
      expect(page).to have_css('table#content-table td', text: 'hippo.txt')

      # Go back to the first page
      click_link_or_button('1')

      # Delete the first file
      expect(page).to have_css('table#content-table td', text: 'hippo.png')
      all('a', text: 'Remove').first.click
      expect(page).to have_no_css('table#content-table td', text: 'hippo.png')
      expect(page).to have_css('table#content-table td', text: 'hippo.svg')
      expect(page).to have_css('table#content-table td', text: 'hippo.txt')

      # Edit the description
      all('a', text: 'Add description').first.click
      fill_in('Description', with: 'This is a hippo.')
      click_link_or_button('Update')

      # The description is updated.
      expect(page).to have_css('table#content-table td', text: 'hippo.svg')
      expect(page).to have_css('table#content-table td', text: 'This is a hippo.')
      content_file = ContentFile.find_by(filepath: 'hippo.svg')
      expect(content_file.label).to eq('This is a hippo.')

      # Hide the file
      all('input[type=checkbox][name="content_file[hide]"]').first.check
      expect(page).to have_field('hide', checked: true)
      sleep 0.25 # Wait for the form to submit.
      expect(content_file.reload.hide).to be true
    end
  end

  context 'when file is too large' do
    before do
      allow(Settings.file_upload).to receive(:max_filesize).and_return(1)
    end

    it 'does not accept the file' do
      visit new_work_path(collection_druid: collection.druid)

      expect(page).to have_css('h1', text: 'Untitled deposit')

      # Add one file
      # This doesn't work in Cyperful
      find('.dropzone').drop('spec/fixtures/files/hippo.tiff')

      expect(page).to have_text('hippo.tiff: File is too big (4.61MiB). Max filesize: 1MiB.')

      expect(page).to have_text('Your files will appear here once they have been uploaded.')

      # Upload a smaller file
      find('.dropzone').drop('spec/fixtures/files/hippo.png')

      within('table#content-table') do
        expect(page).to have_css('td:nth-of-type(1)', text: 'hippo.png') # Filename
      end
      expect(page).to have_no_text('hippo.tiff: File is too big (4.61MiB). Max filesize: 1MiB.')
    end
  end

  context 'when too many files', :headed_test do
    before do
      allow(Settings.file_upload).to receive(:max_files).and_return(1)
    end

    it 'does not accept the file' do
      visit new_work_path(collection_druid: collection.druid)

      expect(page).to have_css('h1', text: 'Untitled deposit')

      # Add one file
      # This doesn't work in Cyperful
      find('.dropzone').drop('spec/fixtures/files/hippo.png')

      within('table#content-table') do
        expect(page).to have_css('td:nth-of-type(1)', text: 'hippo.png') # Filename
      end

      find('.dropzone').drop('spec/fixtures/files/hippo.svg')
      expect(page).to have_text('hippo.svg: You can not upload any more files.')
    end
  end
end
