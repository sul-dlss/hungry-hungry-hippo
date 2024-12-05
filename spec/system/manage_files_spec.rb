# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Manage files for a work' do
  let(:user) { create(:user) }
  let(:collection) { create(:collection, :with_druid, user:) }

  before do
    Kaminari.configure do |config|
      config.default_per_page = 2
    end

    sign_in(user)
  end

  it 'creates a work' do
    visit new_work_path(collection_druid: collection.druid)

    expect(page).to have_css('h1', text: 'Untitled deposit')

    expect(page).to have_text('Your files will appear here once they have been uploaded.')

    # Add one file
    # This doesn't work in Cyperful
    find('.dropzone').drop('spec/fixtures/files/hippo.png')

    expect(page).to have_css('table#content-table td', text: 'hippo.png')
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
    all('a', text: 'Edit').first.click
    fill_in('Description', with: 'This is a hippo.')
    click_link_or_button('Update')

    # The description is updated.
    expect(page).to have_css('table#content-table td', text: 'hippo.svg')
    expect(page).to have_css('table#content-table td', text: 'This is a hippo.')
    content_file = ContentFile.find_by(filename: 'hippo.svg')
    expect(content_file.label).to eq('This is a hippo.')

    # Hide the file
    all('input[type=checkbox][name="content_file[hide]"]').first.check
    expect(page).to have_field('hide', checked: true)
    expect(content_file.reload.hide).to be true
  end
end
