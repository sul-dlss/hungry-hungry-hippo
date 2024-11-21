# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Manage files for a work' do
  before do
    sign_in(create(:user))
  end

  it 'creates a work' do
    visit new_work_path

    expect(page).to have_css('h1', text: 'Untitled deposit')

    expect(page).to have_css('.alert-warning', text: 'No files uploaded.')

    # Add one file
    attach_file('content_files', 'spec/fixtures/files/hippo.png')
    click_link_or_button('Upload')

    expect(page).to have_css('table#content-table td', text: 'hippo.png')

    # Add another file
    attach_file('content_files', 'spec/fixtures/files/hippo.svg')
    click_link_or_button('Upload')

    # Now both are listed.
    expect(page).to have_css('table#content-table td', text: 'hippo.png')
    expect(page).to have_css('table#content-table td', text: 'hippo.svg')

    # Delete the first file
    all('a', text: 'Remove').first.click
    expect(page).to have_no_css('table#content-table td', text: 'hippo.png')
    expect(page).to have_css('table#content-table td', text: 'hippo.svg')

    # Edit the description
    click_link_or_button('Edit')
    fill_in('Description', with: 'This is a hippo.')
    click_link_or_button('Update')

    # The description is updated.
    expect(page).to have_css('table#content-table td', text: 'hippo.svg')
    expect(page).to have_css('table#content-table td', text: 'This is a hippo.')
  end
end
