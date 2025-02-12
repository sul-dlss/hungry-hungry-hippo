# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show terms of deposit' do
  before do
    sign_in(create(:user))
  end

  it 'displays the terms of deposit modal' do
    visit root_path

    click_link_or_button 'Terms of Deposit'

    within('.modal#tod-modal') do
      expect(page).to have_css('h1', text: 'Terms of Deposit')
      expect(page).to have_text('In depositing content to the Stanford Digital Repository')
      find('.btn-close').click
    end

    expect(page).to have_css('.modal#tod-modal[aria-hidden="true"]', visible: :hidden)
  end
end
