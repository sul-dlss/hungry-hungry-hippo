# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a draft' do
  let(:druid) { 'druid:bc123df4567' }

  let(:cocina_object) do
    build(:dro, title: 'My Work', id: druid)
  end

  before do
    # Stubbing out for Deposit Job
    allow(Sdr::Repository).to receive(:register) do |args|
      cocina_params = args[:cocina_object].to_h
      cocina_params[:externalIdentifier] = druid
      cocina_params[:description][:purl] = "https://purl.stanford.edu/#{druid.delete_prefix('druid:')}"
      cocina_params[:structural] = {}
      Cocina::Models.build(cocina_params)
    end
    allow(Sdr::Repository).to receive(:accession)
    # Stubbing out for show page
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)

    sign_in(create(:user))
  end

  it 'creates a work' do
    visit new_work_path

    expect(page).to have_css('h1', text: 'Untitled deposit')

    # Testing tabs
    # Title tab is active, abstract is not
    expect(page).to have_css('.nav-link.active', text: 'Title')
    expect(page).to have_css('.nav-link:not(.active)', text: 'Abstract')
    # Title pane with form field is visible, abstract is not
    expect(page).to have_text('Title of deposit')
    expect(page).to have_field('work_title', type: 'text')
    expect(page).to have_no_text('Describe your deposit')

    # Filling in title
    fill_in('work_title', with: 'My Work')

    # Clicking on abstract tab
    find('.nav-link', text: 'Abstract').click
    expect(page).to have_css('.nav-link.active', text: 'Abstract')
    expect(page).to have_text('Describe your deposit')

    # Depositing the work
    find('.nav-link', text: 'Deposit').click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Deposit')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: 'My Work')
  end
end
