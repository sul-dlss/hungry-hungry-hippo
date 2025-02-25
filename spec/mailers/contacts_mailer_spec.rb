# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactsMailer do
  let(:params) do
    {
      name: 'George Oscar Bluth II',
      email_address: 'gob@stanford.edu',
      affiliation: 'Bluth Company',
      help_how: 'I want to report a problem',
      message: "I've made a huge mistake.",
      collections: %i[faculty_student_staff_collection research_data_collection]
    }
  end

  describe '#jira_email' do
    let(:mail) { described_class.with(**params).jira_email }

    it 'renders the headers' do
      expect(mail.subject).to eq 'I want to report a problem'
      expect(mail.to).to eq [Settings.jira_email, Settings.support_email]
      expect(mail.from).to eq ['gob@stanford.edu']
    end

    it 'renders the body' do
      expect(mail).to match_body('George Oscar Bluth II')
      expect(mail).to match_body('Bluth Company')
      expect(mail).to match_body("I've made a huge mistake.")
      expect(mail).to match_body('Faculty, Student, and Staff Publications; Stanford Research Data')
    end
  end
end
