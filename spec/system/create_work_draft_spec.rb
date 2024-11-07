# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a work draft' do
  before do
    sign_in(create(:user))
  end

  it 'creates a work draft' do
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
    # Clicking on abstract tab
    find('.nav-link', text: 'Abstract').click
    expect(page).to have_css('.nav-link.active', text: 'Abstract')
    expect(page).to have_text('Describe your deposit')
  end
end
