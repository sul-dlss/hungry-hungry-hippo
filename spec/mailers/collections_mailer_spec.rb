# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionsMailer do
  let(:user) { create(:user, name: 'Max Headroom', first_name: 'Maxwell') }
  let(:collection) { create(:collection, title: '20 Minutes into the Future') }

  describe '#invitation_to_deposit_email' do
    let(:mail) { described_class.with(user:, collection:).invitation_to_deposit_email }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Invitation to deposit to the 20 Minutes into the Future collection in the SDR'
      expect(mail.to).to eq [user.email_address]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body with salutation of first name' do
      expect(mail).to match_body('Dear Maxwell,')
      expect(mail).to match_body('You have been invited to deposit to the 20 Minutes into the Future collection')
      expect(mail).to match_body('Subscribe to the SDR newsletter')
    end
  end

  describe '#manage_access_granted_email' do
    let(:mail) { described_class.with(user:, collection:).manage_access_granted_email }

    it 'renders the headers' do
      expect(mail.subject).to eq 'You are invited to participate as a Manager in the 20 Minutes into the Future ' \
                                 'collection in the SDR'
      expect(mail.to).to eq [user.email_address]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body).to include('Dear Maxwell,')
      expect(mail.body).to match('You have been invited to be a Manager ' \
                                 'of the 20 Minutes into the Future collection')
      expect(mail.body).to match('Subscribe to the SDR newsletter')
    end
  end
end
