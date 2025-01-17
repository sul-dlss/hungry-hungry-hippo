# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Validate a work deposit' do
  let(:user) { create(:user) }
  let(:collection) { create(:collection, :with_druid, user:) }
  let(:work_path_with_collection) { new_work_path(collection_druid: collection.druid) }

  before do
    sign_in(user)
  end

  it 'validates a work' do
    visit work_path_with_collection

    expect(page).to have_css('h1', text: 'Untitled deposit')

    # File is required for deposit, but skipping.

    # Filling in title
    find('.nav-link', text: 'Title & contact').click
    fill_in('work_title', with: title_fixture)
    # Contact email is required, but skipping.

    # Abstract is required for deposit, but skipping.

    # Bad date
    find('.nav-link', text: 'Dates (optional)').click
    expect(page).to have_css('.nav-link.active', text: 'Dates (optional)')
    fill_in('Year', with: 'abc')

    # Clicking on related content tab & filling in related link text and *not* URL (which is required for deposit)
    find('.nav-link', text: 'Related content (optional)').click
    expect(page).to have_css('.nav-link.active', text: 'Related content (optional)')
    fill_in('Link text', with: related_links_fixture.first['text'])

    # Providing an invalid release date
    find('.nav-link', text: 'Access settings').click
    expect(page).to have_css('.nav-link.active', text: 'Access settings')
    choose('On this date')
    fill_in('Release date', with: (Time.zone.today - 1.day).iso8601)

    # Depositing the work
    find('.nav-link', text: 'Deposit').click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Deposit')
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_current_path(work_path_with_collection)

    # Alert
    expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')

    # Manage file is marked invalid
    expect(page).to have_css('.nav-link.active.is-invalid', text: 'Manage files')
    expect(page).to have_css('.invalid-feedback.is-invalid', text: 'must have at least one file')

    find('.dropzone').drop('spec/fixtures/files/hippo.png')

    expect(page).to have_css('table#content-table td', text: 'hippo.png')

    # Contact email is marked invalid
    find('.nav-link.is-invalid', text: 'Title & contact').click
    expect(page).to have_field('Contact email', class: 'is-invalid')
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")
    fill_in('Contact email', with: contact_emails_fixture.first['email'])

    # Authors is marked invalid
    find('.nav-link.is-invalid', text: 'Authors').click
    expect(page).to have_css('input.is-invalid#work_authors_attributes_0_first_name') # rubocop:disable Capybara/SpecificMatcher
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")
    expect(page).to have_css('input.is-invalid#work_authors_attributes_0_last_name') # rubocop:disable Capybara/SpecificMatcher

    # Fill in the author name
    fill_in('First name', with: authors_fixture.first['first_name'])
    fill_in('Last name', with: authors_fixture.first['last_name'])

    # Abstract is marked invalid
    find('.nav-link.is-invalid', text: 'Abstract').click
    expect(page).to have_css('.nav-link', text: 'Abstract')
    expect(page).to have_css('textarea.is-invalid#work_abstract')
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")

    # Make the abstract valid
    fill_in('Abstract', with: abstract_fixture)

    # Work type is marked invalid
    find('.nav-link', text: 'Type of deposit').click
    expect(page).to have_css('.nav-link.active', text: 'Type of deposit')
    expect(page).to have_field('work_work_type_text', class: 'is-invalid', type: :radio)
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")

    # Make the abstract valid
    choose('Text')

    # Publication date is marked invalid
    find('.nav-link.is-invalid', text: 'Dates (optional)').click
    expect(page).to have_field('work_publication_date_attributes_year', class: 'is-invalid')
    expect(page).to have_css('.invalid-feedback.is-invalid', text: 'must be greater than or equal to 1000')
    fill_in('Year', with: '2024')

    # Related content is marked invalid
    find('.nav-link.is-invalid', text: 'Related content (optional)').click
    expect(page).to have_field('work_related_links_attributes_0_url', class: 'is-invalid')
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")

    # Make the related link valid
    fill_in('URL', with: related_links_fixture.first['url'])

    # Access settings is marked invalid
    find('.nav-link.is-invalid', text: 'Access settings').click
    expect(page).to have_field('Release date', class: 'is-invalid')
    expect(page).to have_css('.invalid-feedback.is-invalid', text: 'must be today or later')
    choose('Immediately')

    # Try to deposit again
    find('.nav-link', text: 'Deposit').click
    click_link_or_button('Deposit')
    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_current_path(work_path_with_collection)

    # No Alert!
    expect(page).to have_no_css('.alert-danger', text: 'Required fields have not been filled out.')
  end
end
