# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Logout' do
  describe 'GET /webauth/logout' do
    let(:user) { create(:user) }

    before do
      cookies[:user_id] = user.id # This should actually be a signed cookie.
    end

    it 'clears the cookie' do
      get '/webauth/logout', headers: authentication_headers_for(user)

      expect(response).to redirect_to(Authentication::SHIBBOLETH_LOGOUT_PATH)
      expect(cookies[:user_id]).to be_empty
    end
  end
end
