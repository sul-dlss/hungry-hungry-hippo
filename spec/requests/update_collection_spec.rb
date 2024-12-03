# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Update collection' do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }

  context 'when the user is not authorized' do
    before do
      create(:collection, druid:)
      sign_in(create(:user))
    end

    it 'redirects to root' do
      put "/collections/#{druid}"

      expect(response).to redirect_to(root_path)
    end
  end
end
