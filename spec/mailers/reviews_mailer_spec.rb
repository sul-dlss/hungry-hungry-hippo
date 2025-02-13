# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReviewsMailer do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:user) { create(:user, name: 'Max Headroom', first_name: 'Maxwell') }
  let(:collection) { create(:collection, title: '20 Minutes into the Future') }
  let(:work) { create(:work, druid:, collection:, user:, title: 'S1.E1: Blipverts', doi_assigned: true) }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(dro_with_metadata_fixture)
    allow(Sdr::Repository).to receive(:status)
      .with(druid:).and_return(instance_double(Dor::Services::Client::ObjectVersion::VersionStatus,
                                               version_description: whats_changing_fixture))
  end

  describe '.submitted_email' do
    let(:mail) { described_class.with(work:).submitted_email }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your deposit is submitted and waiting for approval'
      expect(mail.to).to eq [user.email_address]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail).to match_body('Dear Maxwell,')
      expect(mail).to match_body('Your deposit, "S1.E1: Blipverts" to the ' \
                                 '20 Minutes into the Future collection in the Stanford Digital Repository, ' \
                                 'is now waiting for review by a collection Manager.')
      expect(mail).to match_body('If you did not recently submit')
    end
  end

  describe '.rejected_email' do
    before do
      work.request_review!
      work.reject_with_reason!(reason: 'Add something to make it pop.')
    end

    let(:mail) { described_class.with(work:).rejected_email }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your deposit has been reviewed and returned'
      expect(mail.to).to eq [user.email_address]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail).to match_body('Dear Maxwell,')
      expect(mail).to match_body('Your deposit, "S1.E1: Blipverts" to the ' \
                                 '20 Minutes into the Future collection in the Stanford Digital Repository, ' \
                                 'has been returned to you')
      expect(mail).to match_body('Add something to make it pop.')
    end
  end

  describe '.approved_email' do
    before do
      work.request_review!
      work.approve!
    end

    let(:mail) { described_class.with(work:).approved_email }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your deposit has been reviewed and approved'
      expect(mail.to).to eq [user.email_address]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail).to match_body('Dear Maxwell,')
      expect(mail).to match_body('Your deposit, "S1.E1: Blipverts", to the ' \
                                 '20 Minutes into the Future collection has been approved')
      expect(mail).to match_body('If you did not recently submit')
      expect(mail).to match_body('License: CC-BY-4.0 Attribution International')
      expect(mail).to match_body('Access level: Stanford Community')
      expect(mail).to match_body('Release: June 10, 2027')
      expect(mail).to match_body('Your work was assigned this DOI: <a href="https://doi.org/10.80343/bc123df4567">https://doi.org/10.80343/bc123df4567</a>')
    end
  end

  describe '.pending_email' do
    let(:mail) { described_class.with(user:, work:).pending_email }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Item ready for review in the 20 Minutes into the Future collection'
      expect(mail.to).to eq [user.email_address]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail).to match_body('Dear Maxwell,')
      expect(mail).to match_body('The item "S1.E1: Blipverts" has been submitted for review ' \
                                 'in the 20 Minutes into the Future collection by Max Headroom')
    end
  end
end
