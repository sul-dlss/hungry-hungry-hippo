# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationCable::Connection do
  context 'with an active session' do
    let(:user) { create(:user) }

    it 'makes a connection' do
      cookies.signed[:user_id] = user.id

      connect
      expect(connection.current_user).to eq user
    end
  end

  context 'without an active session' do
    it 'rejects the connection' do
      expect { connect }.to have_rejected_connection
    end
  end
end
