# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Manage shares' do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user) }

  before do
    create(:work, druid:, user:)
  end

  context 'when the user is not authorized' do
    context 'when just some user' do
      before do
        sign_in(create(:user))
      end

      it 'redirects to root' do
        get "/works/#{druid}/shares/new"

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the user owns the work' do
      before do
        sign_in(user)
      end

      it 'renders the page' do
        get "/works/#{druid}/shares/new"

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
