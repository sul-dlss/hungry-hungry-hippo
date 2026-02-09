# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Fast Controller' do
  include_context 'with FAST connection'

  let(:query) { 'tea' }

  before do
    sign_in(create(:user))
  end

  context 'when lookup is successful' do
    # returns the first ten deduplicated _authorized_ forms of FAST terms that match the entered letters.
    let(:suggestions) do
      [
        { 'Tea' => 'http://id.worldcat.org/fast/1144120::topic' },
        { 'Tea Party movement' => 'http://id.worldcat.org/fast/1762507::topic' },
        { 'Tea making paraphernalia' => 'http://id.worldcat.org/fast/1144165::topic' },
        { 'Tea tax (American colonies)' => 'http://id.worldcat.org/fast/1144178::topic' },
        { 'Tea trade' => 'http://id.worldcat.org/fast/1144179::topic' },
        { 'Tea--Health aspects' => 'http://id.worldcat.org/fast/1144131::topic' },
        { 'Tea--Social aspects' => 'http://id.worldcat.org/fast/1144144::topic' },
        { 'Tea--Therapeutic use' => 'http://id.worldcat.org/fast/1144148::topic' },
        { 'Tearooms' => 'http://id.worldcat.org/fast/1144712::topic' },
        { 'East India Company' => 'http://id.worldcat.org/fast/537796::organization' }
      ]
    end

    before do
      sign_in(create(:user))
    end

    it 'returns status 200 and html with suggestions' do
      get '/fast', params: { q: query }
      expect(response).to have_http_status :ok

      suggestions.each do |suggestion|
        actual_suggestion = suggestion.keys.first
        uri = suggestion.values.first
        li_element_html = '<li class="list-group-item" role="option" ' \
                          "data-autocomplete-value=\"#{uri}\" data-autocomplete-label=\"#{actual_suggestion}\">" \
                          "#{actual_suggestion}</li>"
        expect(response.body).to include(li_element_html)
      end
    end
  end

  context 'when error is received from the lookup server' do
    let(:lookup_status) { [404, 'some error message'] }
    let(:lookup_response_body) { '' }

    before do
      allow(Rails.logger).to receive(:warn)
      allow(Honeybadger).to receive(:notify)
    end

    it 'returns status 500 and an empty body' do
      get '/fast', params: { q: query }
      expect(response).to have_http_status :internal_server_error
      expect(response.body).to be_empty
      expect(Rails.logger).to have_received(:warn).with('Autocomplete results for tea returned 404')
      expect(Honeybadger).to have_received(:notify)
        .with('FAST API Error', context: hash_including(:query, :response, :url)).once
    end
  end

  context 'when malformed JSON is received from the lookup server' do
    let(:lookup_status) { 200 }
    let(:lookup_response_body) do
      <<~MALFORMED_JSON
        Status: 400
        Reason: Bad Request
      MALFORMED_JSON
    end

    before do
      allow(Rails.logger).to receive(:warn)
      allow(Honeybadger).to receive(:notify)
    end

    it 'returns status 500 and an empty body' do
      get '/fast', params: { q: query }
      expect(response).to have_http_status :internal_server_error
      expect(response.body).to be_empty
      expect(Rails.logger).to have_received(:warn)
        .with("Autocomplete results for tea returned unexpected response 'Status: 400\n" \
              "Reason: Bad Request\n" \
              "'")
      expect(Honeybadger).to have_received(:notify)
        .with('Unexpected response from FAST API', context: hash_including(:query, :response, :url, :exception)).once
    end
  end
end
