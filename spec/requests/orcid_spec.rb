# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Orcid' do
  before { sign_in(create(:user)) }

  describe 'GET /search' do
    context 'when search successful' do
      before do
        allow(OrcidResolver).to receive(:call).and_return(Dry::Monads::Result::Success.new(%w[Wilford Brimley]))
      end

      it 'returns the data' do
        get '/orcid?id=0000-0003-1527-0030'

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('{"orcid":"0000-0003-1527-0030","first_name":"Wilford","last_name":"Brimley"}')
        expect(OrcidResolver).to have_received(:call).with(orcid_id: '0000-0003-1527-0030')
      end
    end

    context 'when search unsuccessful' do
      before do
        allow(OrcidResolver).to receive(:call).and_return(Dry::Monads::Result::Failure.new(404))
      end

      it 'returns status' do
        get '/orcid?id=0000-0003-1527-0030'

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
