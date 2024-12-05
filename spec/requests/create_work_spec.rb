# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create work' do
  context 'when the user is not authorized' do
    before do
      create(:collection, druid: collection_druid_fixture)
      sign_in(create(:user))
    end

    it 'redirects to root' do
      post '/works', params: { work: { collection_druid: collection_druid_fixture } }

      expect(response).to redirect_to(root_path)
    end
  end
end
