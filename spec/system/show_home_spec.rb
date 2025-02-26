# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show home', :rack_test do
  include ActionView::Helpers::SanitizeHelper

  context 'when the user is not authorized to see the dashboard' do
    before do
      sign_in(create(:user))
    end

    it 'shows the home page' do
      visit root_path

      expect(page).to have_content('Create or manage your deposits')
      expect(page).to have_link('Enter here', href: dashboard_path)
      expect(page).to have_content(strip_links(I18n.t('banner.home_html')))
      expect(page).to have_content('Sign up for our newsletter')
      expect(page).to have_css('.quote-card', text: 'I am definitely hearing more')
      expect(page).to have_css('.quote-card', count: 5)
    end
  end

  context 'when the user is authorized to see the dashboard' do
    before do
      sign_in(create(:user), groups: [Settings.authorization_workgroup_names.collection_creators])
    end

    it 'redirects to the dashboard' do
      visit root_path

      expect(page).to have_current_path(dashboard_path)
    end
  end
end
