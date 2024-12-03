# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Validate a work deposit' do
  let(:user) { create(:user) }
  let(:collection) { create(:collection, user:) }
  let(:work_path_with_collection) { new_work_path(collection_druid: collection.druid) }

  before do
    sign_in(user)
  end

  it 'validates a work' do
    visit work_path_with_collection

    expect(page).to have_css('h1', text: 'Untitled deposit')

    # Filling in title
    find('.nav-link', text: 'Title').click
    fill_in('work_title', with: title_fixture)

    # Abstract is required for deposit, but skipping.

    # Bad date
    find('.nav-link', text: 'Dates (optional)').click
    expect(page).to have_css('.nav-link.active', text: 'Dates (optional)')
    fill_in('Year', with: 'abc')

    # Clicking on related content tab & filling in related link text and *not* URL (which is required for deposit)
    find('.nav-link', text: 'Related content (optional)').click
    expect(page).to have_css('.nav-link.active', text: 'Related content (optional)')
    fill_in('Link text', with: related_links_fixture.first['text'])

    # License is required for deposit, but skipping.

    # Depositing the work
    find('.nav-link', text: 'Deposit').click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Deposit')
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_current_path(work_path_with_collection)

    # Alert
    expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')

    # Abstract is marked invalid
    expect(page).to have_css('.nav-link.active', text: 'Abstract')
    expect(page).to have_css('textarea.is-invalid#work_abstract')
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")

    # Make the abstract valid
    fill_in('Abstract', with: abstract_fixture)

    # Publication date is marked invalid
    expect(page).to have_css('.nav-link', text: 'Dates (optional)')
    find('.nav-link', text: 'Dates (optional)').click
    expect(page).to have_css('input.is-invalid#work_publication_date_attributes_year') # rubocop:disable Capybara/SpecificMatcher
    expect(page).to have_css('.invalid-feedback.is-invalid', text: 'must be greater than or equal to 1000')
    fill_in('Year', with: '2024')

    # Related content is marked invalid
    expect(page).to have_css('.nav-link', text: 'Related content (optional)')
    find('.nav-link', text: 'Related content (optional)').click
    expect(page).to have_css('input.is-invalid#work_related_links_attributes_0_url') # rubocop:disable Capybara/SpecificMatcher
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")

    # Make the related link valid
    fill_in('URL', with: related_links_fixture.first['url'])

    # License is marked invalid
    find('.nav-link', text: 'License').click
    expect(page).to have_css('.nav-link.is-invalid', text: 'License')
    expect(page).to have_css('select.is-invalid#work_license') # rubocop:disable Capybara/SpecificMatcher
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")

    # Select the license
    select('CC-BY-4.0 Attribution International', from: 'work_license')

    # Try to deposit again
    find('.nav-link', text: 'Deposit').click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Deposit')
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_current_path(work_path_with_collection)

    # No Alert!
    expect(page).to have_no_css('.alert-danger', text: 'Required fields have not been filled out.')
  end
end
