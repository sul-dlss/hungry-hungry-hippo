# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountService do
  subject(:account) { described_class.call(id:) }

  let(:person_api_response) do
    <<~XML
      <Person listing="world" name="Coyne, Justin Michael" regid="567abc" relationship="staff" source="registry" sunetid="jcoyne85" univid="56789">
        <name type="registered" visibility="none">
          <first nval="test">Justin Michael</first>
          <middle nval="t">Michael</middle>
          <last nval="test">Coyne</last>
        </name>
        <name type="display" visibility="world">
          <first nval="test">Justin</first>
          <middle nval="t">Michael</middle>
          <last nval="test">Coyne</last>
        </name>
        <title type="job" visibility="world">Digital Library Systems and Services</title>
      </Person>
    XML
  end
  let(:id) { 'jcoyne85' }

  before do
    allow(MaisPersonClient).to receive(:fetch_user).and_return(person_api_response)
  end

  context 'with a blank string' do
    let(:id) { '' }

    it 'returns nil' do
      expect(account).to be_nil
    end
  end

  context 'when not found' do
    let(:person_api_response) { nil }

    it 'returns nil' do
      expect(account).to be_nil
    end
  end

  context 'when the API returns a successful response' do
    before do
      create(:user, name: 'Justin Coyne', email_address: 'jcoyne85@stanford.edu')
    end

    it 'returns an Account with the expected attributes' do
      expect(account.to_h).to match(
        sunetid: 'jcoyne85',
        name: 'Justin Coyne',
        description: 'Digital Library Systems and Services'
      )
    end
  end

  context 'when an email address is provided' do
    let(:id) { 'jcoyne85@stanford.edu' }

    before do
      create(:user, name: 'Justin Coyne', email_address: 'jcoyne85@stanford.edu')
    end

    it 'normalizes the id by removing the email domain' do
      expect(account.to_h).to match(
        sunetid: 'jcoyne85',
        name: 'Justin Coyne',
        description: 'Digital Library Systems and Services'
      )
    end
  end

  context 'when an uppercase id is provided' do
    let(:id) { 'JCOYNE85' }

    before do
      create(:user, name: 'Justin Coyne', email_address: 'jcoyne85@stanford.edu')
    end

    it 'normalizes the id by downcasing it' do
      expect(account.to_h).to match(
        sunetid: 'jcoyne85',
        name: 'Justin Coyne',
        description: 'Digital Library Systems and Services'
      )
    end
  end
end
