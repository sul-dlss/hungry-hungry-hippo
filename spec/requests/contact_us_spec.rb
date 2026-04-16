# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contact us' do
  let(:contact_params) do
    { contact: { name: 'Jane Stanford', email_address: 'jane@stanford.edu', affiliation: 'Founder',
                 help_how: 'I want to ask a question', message: 'How does this work?' } }
  end

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

  describe 'POST /contacts' do
    context 'when recaptcha passes' do
      it 'sends the contact email and renders success' do
        post contacts_path, params: contact_params

        expect(response).to have_http_status(:created)
        expect(response.body).to include('Help request successfully sent')
        expect(ActionMailer::Base.deliveries.last.subject).to eq('I want to ask a question')
      end
    end

    context 'when recaptcha fails' do
      before do
        allow_any_instance_of(ContactsController).to receive(:verify_recaptcha).and_return(false) # rubocop:disable RSpec/AnyInstance
      end

      it 'renders the form with an error and does not send email' do
        expect { post contacts_path, params: contact_params }.not_to change(ActionMailer::Base.deliveries, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('reCAPTCHA challenge failed.')
      end
    end
  end
end
