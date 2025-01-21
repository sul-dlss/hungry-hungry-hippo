# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show terms of deposit' do
  before do
    sign_in(create(:user))
  end

  it 'returns the terms of deposit' do
    get '/terms'

    expect(response).to be_successful
    expect(response.body).to include('<turbo-frame id="terms-of-deposit">')
    expect(response.body).to include('In depositing content to the Stanford Digital Repository')
  end
end
