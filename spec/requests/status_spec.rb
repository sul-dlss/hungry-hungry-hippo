# frozen_string_literal: true

require 'rails_helper'

# This is testing the status page that is provided by the Rails health check gem.
# This test is being used to establish a coverage baseline for CodeClimate in CI
# This can be removed once we have actual tests in place.
RSpec.describe 'Status Page' do
  describe 'GET /up' do
    before do
      get '/up'
    end

    it 'returns an http OK' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a green background' do
      expect(response.body).to include('background-color: green')
    end
  end
end
