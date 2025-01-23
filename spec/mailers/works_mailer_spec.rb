# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorksMailer do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user, name: 'Max Headroom', first_name: 'Maxwell') }
  let(:collection) { create(:collection, title: '20 Minutes into the Future') }
  let(:work) { create(:work, druid:, collection:, user:, title: 'S1.E2: Rakers', doi_assigned: true) }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
    allow(Sdr::Repository).to receive(:status)
      .with(druid:).and_return(instance_double(Dor::Services::Client::ObjectVersion::VersionStatus))
  end

  describe '.deposited_email' do
    let(:mail) { described_class.with(work:).deposited_email }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your deposit, S1.E2: Rakers, is published in the SDR'
      expect(mail.to).to eq [user.email_address]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail).to match_body('Dear Maxwell,')
      expect(mail).to match_body('Your deposit, "S1.E2: Rakers" is now published in the ' \
                                 '20 Minutes into the Future collection in the Stanford Digital Repository.')

      expect(mail).to match_body('License: CC-BY-4.0 Attribution International')
      expect(mail).to match_body('Your work was assigned this DOI: <a href="https://doi.org/10.80343/bc123df4567">https://doi.org/10.80343/bc123df4567</a>')
    end
  end

  describe '.new_version_deposited_email' do
    let(:mail) { described_class.with(work:).new_version_deposited_email }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Updates to S1.E2: Rakers have been deposited in the SDR'
      expect(mail.to).to eq [user.email_address]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail).to match_body('Dear Maxwell,')
      expect(mail).to match_body('Updates to your deposit, "S1.E2: Rakers," are now published in the ' \
                                 '20 Minutes into the Future collection in the Stanford Digital Repository.')

      expect(mail).to match_body('License: CC-BY-4.0 Attribution International')
      expect(mail).to match_body('Your work was assigned this DOI: <a href="https://doi.org/10.80343/bc123df4567">https://doi.org/10.80343/bc123df4567</a>')
    end
  end
end
