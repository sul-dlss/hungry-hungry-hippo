# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermsMailer do
  let(:user) { create(:user, name: 'Howard', first_name: 'Moe') }

  describe '.reminder_email' do
    let(:mail) { described_class.with(user:).reminder_email }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Annual Notice of the Stanford Digital Repository (SDR) Terms of Deposit'
      expect(mail.to).to eq [user.email_address]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      # not checking the full body but a couple parts
      expect(mail.body.encoded).to include('Dear Moe,')
      expect(mail.body.encoded).to include('You are receiving this email as a current or past user')
    end
  end
end
