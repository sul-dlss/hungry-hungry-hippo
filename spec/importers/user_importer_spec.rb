# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserImporter do
  let(:user_json) do
    {
      id: 932,
      email: 'joeb@stanford.edu',
      created_at: '2021-08-02T13:11:57.482Z',
      updated_at: '2024-02-24T02:30:22.262Z',
      name: 'Joe Besser',
      last_work_terms_agreement: nil,
      first_name: 'Joe'
    }.stringify_keys
  end

  context 'when user already exists' do
    let!(:user) { create(:user, email_address: 'joeb@stanford.edu') }

    it 'does not create a new user' do
      expect { described_class.call(user_json:) }.not_to change(User, :count)
    end

    it 'returns user' do
      expect(described_class.call(user_json:)).to eq(user)
    end
  end

  context 'when user does not exist' do
    it 'creates a new user' do
      expect { described_class.call(user_json:) }.to change(User, :count).by(1)
    end

    it 'returns a populated user' do
      user = described_class.call(user_json:)

      expect(user.email_address).to eq('joeb@stanford.edu')
      expect(user.name).to eq('Joe Besser')
      expect(user.first_name).to eq('Joe')
    end
  end

  context 'when user does not have a name' do
    let(:user_json) do
      {
        id: 932,
        email: 'joeb@stanford.edu',
        created_at: '2021-08-02T13:11:57.482Z',
        updated_at: '2024-02-24T02:30:22.262Z',
        name: nil,
        last_work_terms_agreement: nil,
        first_name: nil
      }.stringify_keys
    end

    it 'returns a populated user' do
      user = described_class.call(user_json:)

      expect(user.email_address).to eq('joeb@stanford.edu')
      expect(user.name).to eq('joeb')
      expect(user.first_name).to be_nil
    end
  end
end
