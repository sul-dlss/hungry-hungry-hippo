# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contact Us' do
  before do
    sign_in(create(:user))
  end

  it 'sends an email' do
    visit root_path

    within('header .navbars') do
      click_link_or_button 'Contact us'
    end

    within('.modal-dialog') do
      expect(page).to have_css('h1', text: 'Contact us')
      fill_in('What is your name?', with: 'Michael Bluth')
      fill_in('What is your email address?', with: 'mb@stanford.edu')
      fill_in('What is your Stanford affiliation?', with: 'Faculty')
      select('I want to report a problem', from: 'How can we help you?')

      click_link_or_button 'Submit' # It doesn't because validation fails

      fill_in('Describe your issue', with: 'I burned it. Down to the ground.')

      click_link_or_button 'Submit'

      expect(page).to have_css('h2', text: 'Help request successfully sent')

      click_link_or_button 'Close'
    end

    expect(page).to have_no_css('h1', text: 'Contact us')

    message = ActionMailer::Base.deliveries.last
    expect(message.subject).to eq('I want to report a problem')
  end
end
