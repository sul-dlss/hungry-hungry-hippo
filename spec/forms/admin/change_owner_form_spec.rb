# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ChangeOwnerForm do
  subject(:form) { described_class.new(sunetid:, name:) }

  describe 'with a valid sunetid' do
    let(:sunetid) { 'janedoe' }
    let(:email_address) { "#{sunetid}#{User::EMAIL_SUFFIX}" }
    let(:name) { 'Jane Doe' }

    context 'when the user does not exist' do
      it 'creates a new user with the given sunetid and name' do
        expect { form.user }.to change(User, :count).by(1)
        expect(form.user.email_address).to eq(email_address)
        expect(form.user.name).to eq(name)
      end
    end

    context 'when the user already exists' do
      let(:sunetid) { 'jdoe' }
      let(:email_address) { "#{sunetid}#{User::EMAIL_SUFFIX}" }
      let(:name) { 'John Doe' }

      before do
        User.create!(email_address:, name:)
      end

      it 'finds or creates the user' do
        expect { form.user }.to not_change(User, :count)
        expect(form.user.email_address).to eq(email_address)
        expect(form.user.name).to eq(name)
      end
    end
  end
end
