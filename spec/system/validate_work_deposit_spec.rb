# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Validate a work deposit' do
  include_context 'with FAST connection'

  let(:user) { create(:user, agreed_to_terms_at: nil) }
  let(:collection) { create(:collection, :with_druid, user:) }
  let(:work_path_with_collection) { new_work_path(collection_druid: collection.druid) }

  let(:query) { 'Biology' } # Used in stubbing out FAST connection

  before do
    allow(DepositWorkJob).to receive(:perform_later)

    sign_in(user)
  end

  it 'validates a work' do
    visit work_path_with_collection

    expect(page).to have_css('h1', text: 'Untitled deposit')

    # File is required for deposit, but skipping.

    # Filling in title
    find('.nav-link', text: 'Title and contact').click
    fill_in('work_title', with: title_fixture)
    # Contact email is required, but removing.
    click_link_or_button('Clear')

    # Abstract is required for deposit, but skipping.

    # Bad publication date
    find('.nav-link', text: 'Dates (optional)').click
    expect(page).to have_css('.nav-link.active', text: 'Dates (optional)')
    within('fieldset#publication_date') do
      fill_in('Year', with: 'abc')
    end

    # Bad creation date
    find('label', text: 'Date range').click
    # Not completing range from
    within_fieldset('create_date_range_to') do
      fill_in('Year', with: '2024')
      select('January', from: 'Month')
      check('Approximate')
    end

    # Clicking on related content tab & filling in related link text and *not* URL (which is required for deposit)
    find('.nav-link', text: 'Related content (optional)').click
    expect(page).to have_css('.nav-link.active', text: 'Related content (optional)')
    fill_in('Link text', with: related_links_fixture.first['text'])

    # Providing an invalid release date
    find('.nav-link', text: 'Access settings').click
    expect(page).to have_css('.nav-link.active', text: 'Access settings')
    choose('On this date')
    fill_in('Release date', with: (Time.zone.today - 1.day).strftime('%m/%d/%Y'))

    # Terms of deposit is required, but skipping.
    find('.nav-link', text: 'Deposit', exact_text: true).click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    expect(page).to have_no_text('You have accepted the Terms of Deposit')
    expect(page).to have_field('I agree to the SDR Terms of Deposit', checked: false)
    expect(page).to have_text('In depositing content to the Stanford Digital Repository')

    # Depositing the work
    click_link_or_button('Deposit', class: 'btn-primary')
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
    find('.nav-link.is-invalid', text: 'Title and contact').click
    expect(page).to have_field('Contact email', class: 'is-invalid')
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")
    fill_in('Contact email', with: contact_emails_fixture.first['email'])
    find_field('Contact email').send_keys(:tab)
    expect(page).to have_no_css('.invalid-feedback.is-invalid', text: "can't be blank")

    # Add a blank contact email. It will be ignored.
    click_link_or_button('Add another contact email')
    expect(page).to have_css('.form-instance', count: 2)

    # Authors is marked invalid
    find('.nav-link.is-invalid', text: 'Contributors').click
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank", visible: :all)

    # Fill in the author name
    within('.orcid-section') do
      find('label', text: 'Enter name manually').click
    end
    fill_in('First name', with: contributors_fixture.first['first_name'])
    fill_in('Last name', with: contributors_fixture.first['last_name'])

    # Add a blank contributor. It will be ignored.
    click_link_or_button('Add another contributor')
    expect(page).to have_css('.form-instance', count: 2)

    # Abstract is marked invalid
    find('.nav-link.is-invalid', text: 'Abstract').click
    expect(page).to have_css('.nav-link', text: 'Abstract')
    expect(page).to have_css('textarea.is-invalid#work_abstract')
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")

    # Make the abstract valid
    fill_in('Abstract', with: abstract_fixture)

    # Keywords are marked invalid
    expect(page).to have_field('Keywords (one per box)', class: 'is-invalid')
    fill_in('Keywords (one per box)', with: keywords_fixture.first['text'])
    # Wait for autocomplete to load. FAST is stubbed out.
    expect(page).to have_css('li.list-group-item', text: 'Tearooms')

    # Work type is marked invalid
    find('.nav-link', text: 'Type of deposit').click
    expect(page).to have_css('.nav-link.active', text: 'Type of deposit')
    expect(page).to have_field('work_work_type_text', class: 'is-invalid', type: :radio)
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")

    # Make the abstract valid
    choose('Text')

    # Publication date is marked invalid
    find('.nav-link.is-invalid', text: 'Dates (optional)').click
    within('fieldset#publication_date') do
      expect(page).to have_field('work_publication_date_attributes_year', class: 'is-invalid')
      expect(page).to have_css('.invalid-feedback.is-invalid', text: 'must be greater than or equal to 1000')
      fill_in('Year', with: '2024')
    end

    # Creation date is marked invalid
    expect(page).to have_css('.invalid-feedback.is-invalid', text: 'must have both a start and end date')
    within_fieldset('create_date_range_from') do
      fill_in('Year', with: '2022')
      select('August', from: 'Month')
      select('2', from: 'Day')
    end

    # Related content is marked invalid
    find('.nav-link.is-invalid', text: 'Related content (optional)').click
    expect(page).to have_field('work_related_links_attributes_0_url', class: 'is-invalid')
    expect(page).to have_css('.invalid-feedback.is-invalid', text: 'is not a valid URL')

    # Make the related link valid
    fill_in('URL', with: related_links_fixture.first['url'])

    # Access settings is marked invalid
    find('.nav-link.is-invalid', text: 'Access settings').click
    expect(page).to have_field('Release date', class: 'is-invalid')
    expect(page).to have_css('.invalid-feedback.is-invalid', text: 'must be today or later')
    choose('Immediately')

    # Deposit is marked invalid
    find('.nav-link.is-invalid', text: 'Deposit').click
    expect(page).to have_field('I agree to the SDR Terms of Deposit', class: 'is-invalid')
    expect(page).to have_css('.invalid-feedback.is-invalid', text: 'must be accepted')
    check('I agree')

    # Try to deposit again
    click_link_or_button('Deposit', class: 'btn-primary')

    # On wait page
    expect(page).to have_text('We are saving your work.')
  end

  context 'when nested field has validation errors' do
    it 'validates a work' do
      visit work_path_with_collection

      expect(page).to have_css('h1', text: 'Untitled deposit')

      # Filling in title
      find('.nav-link', text: 'Title and contact').click
      fill_in('work_title', with: title_fixture)

      find('.nav-link', text: 'Contributors').click

      # Fill in the author name only
      within('.orcid-section') do
        find('label', text: 'Enter name manually').click
      end
      fill_in('First name', with: contributors_fixture.first['first_name'])

      click_link_or_button('Save as draft')

      expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')
    end
  end

  context 'when standalone error (must have one contributor)' do
    it 'validates a work' do
      visit work_path_with_collection

      expect(page).to have_css('h1', text: 'Untitled deposit')

      find('.nav-link', text: 'Contributors').click

      # Fill in the author name only
      within('.orcid-section') do
        find('label', text: 'Enter name manually').click
      end

      find('.nav-link', text: 'Deposit', exact_text: true).click
      click_link_or_button('Deposit', class: 'btn-primary')

      expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')

      find('.nav-link.is-invalid', text: 'Contributors').click
      expect(page).to have_css('.invalid-feedback.is-invalid', text: 'must have at least one contributor')
      expect(page).to have_css('.invalid-feedback.is-invalid', text: 'must provide a last name')

      # Provide a last name
      fill_in('Last name', with: contributors_fixture.first['last_name'])
      fill_in('First name', with: contributors_fixture.first['first_name'])
      find_field('First name').send_keys(:tab)
      expect(page).to have_css('.invalid-feedback.is-invalid', text: 'must have at least one contributor')
      expect(page).to have_no_css('.invalid-feedback.is-invalid', text: 'must provide a last name')
      expect(page).to have_css('.nav-link.is-invalid', text: 'Contributors')

      # Add another contributor to clear the error
      click_link_or_button('Add another contributor')
      expect(page).to have_no_css('.invalid-feedback.is-invalid', text: 'must have at least one contributor')
      expect(page).to have_css('.nav-link:not(.is-invalid)', text: 'Contributors')
    end
  end
end
