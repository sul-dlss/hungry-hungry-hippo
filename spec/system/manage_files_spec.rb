# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Manage files for a work' do
  let(:user) { create(:user) }
  let(:collection) { create(:collection, user:) }

  before do
    Kaminari.configure do |config|
      config.default_per_page = 2
    end

    sign_in(user)
  end

  it 'creates a work' do
    visit new_work_path(collection_id: collection.id)

    expect(page).to have_css('h1', text: 'Untitled deposit')

    expect(page).to have_css('.alert-warning', text: 'No files uploaded.')

    # Add one file
    attach_file('content_files', 'spec/fixtures/files/hippo.png')
    click_link_or_button('Upload')

    expect(page).to have_css('table#content-table td', text: 'hippo.png')
    expect(page).to have_no_css('ul.pagination')

    # Add 2 more files
    attach_file('content_files', 'spec/fixtures/files/hippo.svg')
    click_link_or_button('Upload')
    expect(page).to have_css('table#content-table td', text: 'hippo.svg')
    attach_file('content_files', 'spec/fixtures/files/hippo.txt')
    click_link_or_button('Upload')

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
  end
end
