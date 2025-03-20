# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contact us' do
  before do
    sign_in(create(:user))
  end

  context 'when a modal' do
    it 'renders the contact form' do
      get '/contacts/new?modal=true'

      expect(response.body).to include('What is your name?')
      expect(response.body).to include('action="/contacts?modal=true&amp;welcome=false"')
      expect(response.body).to include('Cancel')
    end
  end

  context 'when welcome' do
    it 'renders the contact form' do
      get '/contacts/new?welcome=true'

      expect(response.body).to include('What is your name?')
      expect(response.body).to include('action="/contacts?modal=false&amp;welcome=true"')
      expect(response.body).to include('<h2>Welcome</h2>')
      expect(response.body).not_to include('Cancel')
    end
  end

  context 'when not a modal' do
    it 'renders the contact form' do
      get '/contacts/new'

      expect(response.body).to include('What is your name?')
      expect(response.body).to include('action="/contacts?modal=false&amp;welcome=false"')
      expect(response.body).not_to include('<h2>Welcome</h2>')
      expect(response.body).not_to include('Cancel')
    end
  end
end
