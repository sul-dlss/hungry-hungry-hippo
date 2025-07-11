# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RorService do
  subject(:response) { described_class.organizations(query:) }

  let(:query) { 'stanford' }
  let(:body) { File.read('spec/fixtures/files/stanford_ror.json') }

  before do
    stub_request(:get, "https://api.ror.org/organizations?query=#{query}")
      .to_return(status: 200, body:, headers: {})
  end

  it 'returns a successful response' do
    response_json = JSON.parse(response)
    expect(response_json['number_of_results']).to eq(1)
    expect(response_json['items'].first['name']).to eq('Stanford University')
  end
end
