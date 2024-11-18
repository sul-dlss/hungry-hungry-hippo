# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard', :rack_test do
  let(:druid) { druid_fixture }
  let!(:work) { create(:work, druid: druid, title: title_fixture, user:) }
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  it 'displays the user name in the header' do
    visit root_path

    expect(page).to have_css('h2', text: "#{user.name} - Dashboard")

    # Works table
    within('table#works-table') do
      expect(page).to have_css('td', text: work.title)
    end
  end
end
