# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorksMailer do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user, name: 'Max Headroom', first_name: 'Maxwell') }
  let(:collection) { create(:collection, title: '20 Minutes into the Future', managers:) }
  let(:work) { create(:work, druid:, collection:, user:, title: 'S1.E2: Rakers', doi_assigned: true) }
  let(:managers) { [] }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
    allow(Sdr::Repository).to receive(:status)
      .with(druid:).and_return(build(:version_status))
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
      expect(mail).to match_body('If you did not recently submit')
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
      expect(mail).to match_body('If you did not recently submit')
      expect(mail).to match_body('License: CC-BY-4.0 Attribution International')
      expect(mail).to match_body('Your work was assigned this DOI: <a href="https://doi.org/10.80343/bc123df4567">https://doi.org/10.80343/bc123df4567</a>')
    end
  end

  describe '.managers_depositing_email' do
    let(:mail) { described_class.with(work:, current_user: user).managers_depositing_email }
    let(:manager) { create(:user, first_name: 'Carter') }
    let(:managers) { [user, manager] }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Item deposit completed in the 20 Minutes into the Future collection'
      expect(mail.to).to eq [manager.email_address]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail).to match_body('Dear Carter,')
      expect(mail).to match_body('The item S1.E2: Rakers has been deposited in the 20 Minutes into the Future ' \
                                 'collection by Max Headroom, a collection manager, or an SDR administrator.')
    end
  end

  describe '.ownership_changed_email' do
    let(:mail) { described_class.with(work:, current_user: user).ownership_changed_email }
    let(:user) { create(:user, first_name: 'Carter') }
    let(:managers) { [user] }
    let(:link_to_work) { '<a href="http://example.com/works/druid:bc123df4567">http://example.com/works/druid:bc123df4567</a>' }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Ownership of S1.E2: Rakers has been changed'
      expect(mail.to).to eq [user.email_address]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail).to match_body('Dear Carter,')
      expect(mail).to match_body("You are now the owner of the item \"#{link_to_work}\" in the " \
                                 'Stanford Digital Repository and have access to manage its ' \
                                 'metadata and files.')
    end
  end
end
