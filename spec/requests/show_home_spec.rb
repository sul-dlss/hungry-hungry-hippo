# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show home' do
  context 'when Google Analytics is enabled' do
    before do
      allow(Settings.google_analytics).to receive(:enabled).and_return(true)

      sign_in(create(:user))
    end

    it 'includes the GA script' do
      get '/'

      expect(response.body).to include('Create or manage your deposits')
      expect(response.body).to include('https://www.googletagmanager.com/gtm.js')
      expect(response.body).to include('https://www.googletagmanager.com/ns.html')
    end
  end
end
