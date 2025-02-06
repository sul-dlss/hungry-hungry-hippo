# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactsMailer do
  let(:contact_form) do
    ContactForm.new(
      name: 'George Oscar Bluth II',
      email_address: 'gob@stanford.edu',
      affiliation: 'Bluth Company',
      help_how: 'I want to report a problem',
      message: "I've made a huge mistake."
    )
  end

  describe '#jira_email' do
    let(:mail) { described_class.with(**contact_form.attributes.symbolize_keys).jira_email }

    it 'renders the headers' do
      expect(mail.subject).to eq contact_form.help_how
      expect(mail.to).to eq [Settings.jira_email, Settings.support_email]
      expect(mail.from).to eq [contact_form.email_address]
    end

    it 'renders the body' do
      expect(mail).to match_body(contact_form.name)
      expect(mail).to match_body(contact_form.affiliation)
      expect(mail).to match_body(contact_form.message)
    end
  end
end
