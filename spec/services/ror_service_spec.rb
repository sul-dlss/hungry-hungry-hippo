# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RorService do
  subject(:organizations) { described_class.call(search:) }

  let(:search) { 'stanford' }
  let(:body) { File.read('spec/fixtures/files/stanford_ror.json') }

  before do
    stub_request(:get, "https://api.ror.org/organizations?query=#{search}")
      .with(headers: { 'Accept' => 'application/json' })
      .to_return(status: 200, body:, headers: { 'Content-Type': 'application/json;charset=UTF-8' })
  end

  it 'returns a successful response' do
    expect(organizations.count).to eq(1)
    expect(organizations.first['name']).to eq('Stanford University')
  end
end
