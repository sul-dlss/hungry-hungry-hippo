# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Manage dates for a work deposit' do
  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let(:version_status) do
    VersionStatus.new(status:
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, accessioning?: true,
                                                                         openable?: false, version: 1,
                                                                         version_description: whats_changing_fixture))
  end

  before do
    # Stubbing out for Deposit Job
    allow(Sdr::Repository).to receive(:register) do |args|
      cocina_params = args[:cocina_object].to_h
      cocina_params[:externalIdentifier] = druid
      cocina_params[:description][:purl] = Sdr::Purl.from_druid(druid:)
      cocina_params[:structural] = { isMemberOf: [collection_druid_fixture] }
      cocina_params[:administrative] = { hasAdminPolicy: Settings.apo }
      cocina_object = Cocina::Models.build(cocina_params)
      @registered_cocina_object = Cocina::Models.with_metadata(cocina_object, 'abc123')
    end
    allow(Sdr::Repository).to receive(:accession)

    # Stubbing out for show page
    allow(Sdr::Repository).to receive(:find).with(druid:).and_invoke(->(_arg) { @registered_cocina_object })
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Doi).to receive(:assigned?).with(druid:).and_return(false)

    create(:collection, user:, druid: collection_druid_fixture)

    sign_in(user)
  end

  it 'manages dates' do
    visit new_work_path(collection_druid: collection_druid_fixture)

    expect(page).to have_css('h1', text: 'Untitled deposit')

    # Filling in title
    find('.nav-link', text: 'Title and contact').click
    fill_in('work_title', with: title_fixture)

    # Go to dates tab
    find('.nav-link', text: 'Dates (optional)').click
    expect(page).to have_text('Enter dates related to your deposit (optional)')

    within_fieldset('publication_date') do
      # Month and day are disabled initially.
      expect(page).to have_field('Year', disabled: false, text: '')
      expect(page).to have_field('Month', disabled: true)
      expect(page).to have_field('Day', disabled: true)
      # They become enabled as fields are filled in.
      fill_in('Year', with: '2024')
      select('June', from: 'Month')
      select('10', from: 'Day')
      # Clear
      click_link_or_button('Clear')
      expect(page).to have_field('Year', disabled: false, text: '')
      expect(page).to have_field('Month', disabled: true)
      expect(page).to have_field('Day', disabled: true)
      fill_in('Year', with: '2024')
      select('June', from: 'Month')
      select('10', from: 'Day')
    end

    expect(page).to have_field('work[create_date_type]', with: 'single', checked: true)
    find('label', text: 'Date range').click
    within_fieldset('create_date_range_from') do
      # Month and day are disabled initially.
      expect(page).to have_field('Year', disabled: false, text: '')
      expect(page).to have_field('Month', disabled: true)
      expect(page).to have_field('Day', disabled: true)
      # Approximate is not checked.
      expect(page).to have_field('Approximate', checked: false)
    end

    within_fieldset('create_date_range_to') do
      # Month and day are disabled initially.
      expect(page).to have_field('Year', disabled: false, text: '')
      expect(page).to have_field('Month', disabled: true)
      expect(page).to have_field('Day', disabled: true)
      # Approximate is not checked.
      expect(page).to have_field('Approximate', checked: false)
    end

    within_fieldset('create_date_range_from') do
      fill_in('Year', with: '2022')
      select('August', from: 'Month')
      select('2', from: 'Day')
      # When you select a day, approximate is disabled.
      expect(page).to have_field('Approximate', checked: false, disabled: true)
    end

    within_fieldset('create_date_range_to') do
      fill_in('Year', with: '2024')
      select('January', from: 'Month')
      check('Approximate')
      # When you check approximate, day is disabled.
      expect(page).to have_field('Day', disabled: true)

      # Clear
      click_link_or_button('Clear')
    end

    # Both from and to are cleared.
    within_fieldset('create_date_range_from') do
      # Month and day are disabled initially.
      expect(page).to have_field('Year', disabled: false, text: '')
      expect(page).to have_field('Month', disabled: true)
      expect(page).to have_field('Day', disabled: true)
      # Approximate is not checked.
      expect(page).to have_field('Approximate', checked: false)
    end

    within_fieldset('create_date_range_to') do
      # Month and day are disabled initially.
      expect(page).to have_field('Year', disabled: false, text: '')
      expect(page).to have_field('Month', disabled: true)
      expect(page).to have_field('Day', disabled: true)
      # Approximate is not checked.
      expect(page).to have_field('Approximate', checked: false)
    end

    # Fill in the date range again
    within_fieldset('create_date_range_from') do
      fill_in('Year', with: '2022')
      select('August', from: 'Month')
      select('2', from: 'Day')
    end

    within_fieldset('create_date_range_to') do
      fill_in('Year', with: '2024')
      select('January', from: 'Month')
      check('Approximate')
    end

    click_link_or_button('Save as draft')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: title_fixture)

    within('table#dates-table') do
      expect(page).to have_css('td', text: '2024-06-10')
      expect(page).to have_css('td', text: '2022-08-02 - 2024-01~')
    end
  end
end
