# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Validate a collection deposit' do
  let(:user) { create(:user) }
  let(:groups) { ['dlss:hydrus-app-collection-creators'] }
  let(:collection_path) { new_collection_path }

  before do
    sign_in(user, groups:)
  end

  it 'validates a work' do
    visit collection_path

    expect(page).to have_css('h1', text: 'Untitled collection')

    # Filling in title
    find('.nav-link', text: 'Title').click
    fill_in('collection_title', with: collection_title_fixture)

    # Description is required for deposit, but skipping.

    # Clicking on related content tab & filling in related link text and *not* URL (which is required for deposit)
    find('.nav-link', text: 'Related content (optional)').click
    expect(page).to have_css('.nav-link.active', text: 'Related content (optional)')
    fill_in('Link text', with: related_links_fixture.first['text'])

    # Depositing the work
    find('.nav-link', text: 'Deposit').click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Deposit')
    expect(page).to have_css('h1', text: collection_title_fixture)
    expect(page).to have_current_path(collection_path)

    # Alert
    expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')

    # Description is marked invalid
    expect(page).to have_css('.nav-link.active', text: 'Description')
    expect(page).to have_css('textarea.is-invalid#collection_description')
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")

    # Make the description valid
    fill_in('Description', with: collection_description_fixture)

    # Related content is marked invalid
    expect(page).to have_css('.nav-link', text: 'Related content (optional)')
    find('.nav-link', text: 'Related content (optional)').click
    expect(page).to have_css('input.is-invalid#collection_related_links_attributes_0_url') # rubocop:disable Capybara/SpecificMatcher
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")

    # Make the related link valid
    fill_in('URL', with: related_links_fixture.first['url'])

    # Try to deposit again
    find('.nav-link', text: 'Deposit').click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Deposit')
    expect(page).to have_css('h1', text: collection_title_fixture)
    expect(page).to have_current_path(collection_path)

    # No Alert!
    expect(page).to have_no_css('.alert-danger', text: 'Required fields have not been filled out.')
  end
end
