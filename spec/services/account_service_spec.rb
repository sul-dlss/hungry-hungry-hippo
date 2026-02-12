# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountService do
  subject(:account) { described_class.call(id:) }

  let(:person_api_response) { '<Person />' }
  let(:person) do
    instance_double(MaisPersonClient::Person,
                    sunetid: 'jcoyne85',
                    display_name: MaisPersonClient::Person::PersonName.new(first_name: 'Justin Michael', last: 'Coyne'),
                    job_title: 'Digital Library Systems and Services, Digital Library Software Engineer - Web & Infrastructure') # rubocop:disable Layout/LineLength
  end
  let(:id) { 'jcoyne85' }

  before do
    allow(MaisPersonClient).to receive(:fetch_user).and_return(person_api_response)
    allow(MaisPersonClient::Person).to receive(:new).with(person_api_response).and_return(person)
  end

  context 'with a blank string' do
    let(:id) { '' }

    it 'returns nil' do
      expect(account).to be_nil
    end
  end

  context 'when not found' do
    let(:person_api_response) { nil }

    it 'returns an empty response' do
      expect(account).to be_nil
    end
  end

  context 'when the API returns a successful response' do
    it 'returns an Account with the expected attributes' do
      expect(account.to_h).to match(
        sunetid: 'jcoyne85',
        name: 'Justin Michael Coyne',
        description: 'Digital Library Systems and Services, Digital Library Software Engineer - Web & Infrastructure'
      )
    end
  end

  context 'when an email address is provided' do
    let(:id) { 'jcoyne85@stanford.edu' }

    it 'normalizes the id by removing the email domain' do
      account
      expect(MaisPersonClient).to have_received(:fetch_user).with('jcoyne85')
    end
  end

  context 'when an uppercase id is provided' do
    let(:id) { 'JCOYNE85' }

    it 'normalizes the id by downcasing it' do
      account
      expect(MaisPersonClient).to have_received(:fetch_user).with('jcoyne85')
    end
  end

  context 'when not found with a downcased id' do
    let(:id) { 'JCOYNE85' }
    let(:person_api_response) { nil }

    it 'attempts to find the user with the original case id' do
      account
      expect(MaisPersonClient).to have_received(:fetch_user).with('jcoyne85')
      expect(MaisPersonClient).to have_received(:fetch_user).with('JCOYNE85')
    end
  end
end
