# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Validate a work deposit' do
  before do
    sign_in(create(:user))
  end

  it 'validates a work' do
    visit new_work_path

    expect(page).to have_css('h1', text: 'Untitled deposit')

    # Filling in title
    fill_in('work_title', with: title_fixture)

    # Abstract is required for deposit, but skipping.

    # Clicking on related content tab & filling in related link text and *not* URL (which is required for deposit)
    find('.nav-link', text: 'Related content (optional)').click
    expect(page).to have_css('.nav-link.active', text: 'Related content (optional)')
    fill_in('Link text', with: related_links_fixture.first['text'])

    # Depositing the work
    find('.nav-link', text: 'Deposit').click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Deposit')
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_current_path(new_work_path)

    # Alert
    expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')

    # Related content is marked invalid
    expect(page).to have_css('.nav-link.active', text: 'Related content (optional)')
    expect(page).to have_css('input.is-invalid#work_related_links_269fc60adb004b0b719031a97aedf5e9_url') # rubocop:disable Capybara/SpecificMatcher
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")

    # Make the related link valid
    fill_in('URL', with: related_links_fixture.first['url'])

    # Try to deposit again
    find('.nav-link', text: 'Deposit').click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Deposit')
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_current_path(new_work_path)

    # Alert
    expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')

    # Abstract is marked invalid
    expect(page).to have_css('.nav-link.active', text: 'Abstract')
    expect(page).to have_css('textarea.is-invalid#work_abstract')
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")

    # Make the abstract valid
    fill_in('Abstract', with: abstract_fixture)

    # Try to deposit again
    find('.nav-link', text: 'Deposit').click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Deposit')
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_current_path(new_work_path)

    # No Alert!
    expect(page).to have_no_css('.alert-danger', text: 'Required fields have not been filled out.')
  end
end
