# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Update work' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }

  context 'when the user is not authorized' do
    before do
      create(:work, druid:)
      sign_in(create(:user))
    end

    it 'redirects to root' do
      put "/works/#{druid}"

      expect(response).to redirect_to(root_path)
    end
  end
end
