# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Collection review workflow automatic assignment' do
  let(:user) { create(:user, name: 'John Swithen', email_address: 'jswithen@stanford.edu') }
  let(:groups) { ['dlss:hydrus-app-collection-creators'] }

  before do
    allow(AccountService).to receive(:call).with(sunetid: 'jswithen')
                         .and_return(AccountService::Account.new(name: 'John Swithen', sunetid: 'jswithen'))
    allow(AccountService).to receive(:call).with(sunetid: 'stepking')
                         .and_return(AccountService::Account.new(name: 'Stephen King', sunetid: 'stepking'))
    sign_in(user, groups:)
  end

  it 'automatically adds managers to reviewers when workflow is enabled', :js do
    visit dashboard_path
    click_link_or_button('Create a new collection')

    # Add another manager in the Participants tab
    find('.nav-link', text: 'Participants').click
    fill_in('managers-textarea', with: 'stepking')
    click_link_or_button('Add managers')
    expect(page).to have_css('.participant-label', text: 'Stephen King (stepking)')
    expect(page).to have_css('.participant-label', text: 'John Swithen (jswithen)')

    # Go to Workflow tab
    find('.nav-link', text: 'Workflow').click
    expect(page).to have_checked_field('No', with: false)
    expect(page).to have_no_css('.reviewers-participants .participant-label')

    # Enable review workflow
    find('label', text: 'Yes').click

    # Check that managers were added as reviewers
    expect(page).to have_css('.reviewers-participants .participant-label', text: 'John Swithen (jswithen)')
    expect(page).to have_css('.reviewers-participants .participant-label', text: 'Stephen King (stepking)')

    # Disable review workflow
    find('label', text: 'No').click
    # The list should still be there but hidden (not easily testable with have_css since it's d-none)

    # Enable again, it should not duplicate if not empty (it's not empty because we just populated it)
    find('label', text: 'Yes').click
    expect(page).to have_css('.reviewers-participants .participant-label', count: 2)

    # Remove one reviewer
    within('.reviewers-participants') do
      click_link_or_button 'Clear Stephen King'
    end
    expect(page).to have_no_css('.reviewers-participants .participant-label', text: 'Stephen King (stepking)')

    # Disable and Enable again, it should still only have John Swithen
    find('label', text: 'No').click
    find('label', text: 'Yes').click
    expect(page).to have_css('.reviewers-participants .participant-label', text: 'John Swithen (jswithen)')
    expect(page).to have_no_css('.reviewers-participants .participant-label', text: 'Stephen King (stepking)')
    expect(page).to have_css('.reviewers-participants .participant-label', count: 1)
  end
end
