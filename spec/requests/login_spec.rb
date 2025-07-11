# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Login' do
  describe 'GET /webauth/login' do
    let(:jar) { ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash) }

    context 'when a user does not exist' do
      let(:user) { build(:user) }

      it 'creates a user and sets a cookie' do
        expect { get '/webauth/login', headers: authentication_headers_for(user) }.to change(User, :count).by(1)

        new_user = User.find_by(email_address: user.email_address)
        expect(new_user.name).to eq(user.name)
        expect(new_user.first_name).to eq(user.first_name)

        expect(response).to redirect_to(root_path)
        expect(jar.signed[:user_id]).to eq(new_user.id)
      end
    end

    context 'when a user does exist' do
      let(:user) { create(:user) }
      let(:headers) do
        {
          Authentication::REMOTE_USER_HEADER => user.email_address,
          Authentication::FULL_NAME_HEADER => 'New name',
          Authentication::FIRST_NAME_HEADER => 'New first name'
        }
      end

      it 'updates the user and sets a cookie' do
        expect { get '/webauth/login', headers: }
          .to change { user.reload.name }
          .to('New name')
          .and change { user.reload.first_name }.to('New first name')

        expect(response).to redirect_to(root_path)
        expect(jar.signed[:user_id]).to eq(user.id)
      end
    end
  end
end
