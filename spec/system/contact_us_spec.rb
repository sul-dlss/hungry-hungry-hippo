# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contact SDR staff' do
  before do
    sign_in(create(:user))
  end

  it 'displays the contact form' do
    visit root_path

    click_link_or_button 'Contact SDR staff'

    within('.modal#contact-form-modal') do
      expect(page).to have_css('h1', text: 'Contact SDR staff')
      fill_in('What is your name?', with: 'Jane Stanford')
      fill_in('What is your email address?', with: 'jane@stanford.edu')
      fill_in('What is your Stanford affiliation?', with: 'Founder')
      expect(page).to have_no_text('Faculty, Student, and Staff Publications ')
      select('Request access to another collection', from: 'How can we help you?')
      check('Stanford Research Data')
      check('Stanford University Open Access Articles')
      fill_in('Describe your issue', with: 'How do I deposit content?')
      expect(page).to have_link('Cancel')
      click_link_or_button('Submit')
    end

    within('.modal#contact-form-modal') do
      expect(page).to have_css('.alert-success', text: 'Help request successfully sent')
      # Form is shown again
      expect(page).to have_field('What is your name?')
      click_link_or_button('Cancel')
    end

    expect(page).to have_css('.modal#contact-form-modal[aria-hidden="true"]', visible: :hidden)

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to include('sdr-support@jirasul.stanford.edu')
    expect(mail.subject).to eq('Request access to another collection')
    expect(mail.from).to eq(['jane@stanford.edu'])
    expect(mail).to match_body('Jane Stanford')
    expect(mail).to match_body('How do I deposit content?')
    expect(mail).to match_body('Collections: Stanford Research Data; Stanford University Open Access Articles')
  end
end
