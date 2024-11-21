# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Validate a work deposit' do
  let(:user) { create(:user) }
  let(:collection) { create(:collection, user:) }

  before do
    sign_in(user)
  end

  it 'validates a work' do
    visit new_work_path(collection_id: collection.id)

    expect(page).to have_css('h1', text: 'Untitled deposit')

    # Filling in title
    find('.nav-link', text: 'Title').click
    fill_in('work_title', with: title_fixture)

    # Abstract is required for deposit, but skipping.

    # Depositing the work
    find('.nav-link', text: 'Deposit').click
    expect(page).to have_css('.nav-link.active', text: 'Deposit')
    click_link_or_button('Deposit')

    expect(page).to have_css('h1', text: title_fixture)
    expect(page).to have_current_path(new_work_path(collection_id: collection.id))

    # Alert
    expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')

    # Abstract is marked invalid
    expect(page).to have_css('.nav-link.active', text: 'Abstract')
    expect(page).to have_css('textarea.is-invalid#work_abstract')
    expect(page).to have_css('.invalid-feedback.is-invalid', text: "can't be blank")
  end
end
