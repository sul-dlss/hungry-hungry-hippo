# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionReportsMailer do
  let(:current_user) do
    create(:user, name: 'Jane Stanford', first_name: 'Jane', email_address: 'jstanford@stanford.edu')
  end

  describe '.collection_report_email' do
    let(:mail) { described_class.with(current_user:).collection_report_email }
    let(:csv_content) { "druid, title\n#druid:bb000cc1111, Example Work" }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Collection report is ready'
      expect(mail.to).to eq ['jstanford@stanford.edu']
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail).to match_body('Dear Jane,')
      expect(mail).to match_body('Your Collection Report from the Stanford Digital Repository ' \
                                 'Admin dashboard is attached.')
      expect(mail.attachments['collection_report.csv']).to be_present
    end
  end
end
