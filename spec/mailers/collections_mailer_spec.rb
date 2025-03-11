# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionsMailer do
  let(:user) { create(:user, name: 'Max Headroom', first_name: 'Maxwell') }
  let(:collection) { create(:collection, :with_druid, title: '20 Minutes into the Future') }

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

  describe '#deposit_access_removed_email' do
    let(:mail) { described_class.with(user:, collection:).deposit_access_removed_email }

    context 'when email depositor on status change is enabled' do
      let(:manager) { create(:user) }
      let(:collection) do
        create(:collection,
               title: '20 Minutes into the Future',
               managers: [manager],
               email_depositors_status_changed: true)
      end

      it 'renders the headers' do
        expect(mail.subject).to eq 'Your Depositor permissions for the 20 Minutes into the Future collection ' \
                                   'in the SDR have been removed'
        expect(mail.to).to eq [user.email_address]
        expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
      end

      it 'renders the body with salutation of first name' do
        expect(mail).to match_body('Dear Maxwell,')
        expect(mail).to match_body('A Manager of the 20 Minutes into the Future collection has updated ' \
                                   'the permissions for this collection and removed you as a depositor.')
        expect(mail).to match_body(manager.email_address)
      end
    end

    context 'when email depositor on status change is disabled' do
      let(:user) { collection.user }

      it 'does not render an email' do
        expect(mail.message).to be_a(ActionMailer::Base::NullMail)
      end
    end
  end

  describe '#manage_access_granted_email' do
    let(:mail) { described_class.with(user:, collection:).manage_access_granted_email }

    context 'when the user is not the collection creator' do
      it 'renders the headers' do
        expect(mail.subject).to eq 'You are invited to participate as a Manager in the 20 Minutes into the Future ' \
                                   'collection in the SDR'
        expect(mail.to).to eq [user.email_address]
        expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
      end

      it 'renders the body' do
        expect(mail).to match_body('Dear Maxwell,')
        expect(mail).to match_body('You have been invited to be a Manager ' \
                                   'of the 20 Minutes into the Future collection')
        expect(mail).to match_body('Subscribe to the SDR newsletter')
      end
    end

    context 'when the user created the collection' do
      let(:user) { collection.user }

      it 'does not render an email' do
        expect(mail.message).to be_a(ActionMailer::Base::NullMail)
      end
    end
  end

  describe '#review_access_granted_email' do
    let(:mail) { described_class.with(user:, collection:).review_access_granted_email }

    it 'renders the headers' do
      expect(mail.subject).to eq 'You are invited to participate as a Reviewer in the 20 Minutes into the Future ' \
                                 'collection in the SDR'
      expect(mail.to).to eq [user.email_address]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail).to match_body('Dear Maxwell,')
      expect(mail).to match_body('You have been invited to review new deposits ' \
                                 'to the 20 Minutes into the Future collection')
      expect(mail).to match_body('Subscribe to the SDR newsletter</a> for feature updates')
    end
  end

  describe '#participants_changed_email' do
    context 'when notify managers and reviewers on participant changes is enabled' do
      let(:collection) do
        create(:collection,
               title: '20 Minutes into the Future',
               managers: [manager],
               email_when_participants_changed: true)
      end
      let(:mail) { described_class.with(user:, collection:).participants_changed_email }
      let(:manager) { create(:user) }

      it 'renders the headers' do
        expect(mail.subject).to eq 'Participant changes for the 20 Minutes into the Future ' \
                                   'collection in the SDR'
        expect(mail.to).to eq [manager.email_address]
        expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
      end

      it 'renders the body' do
        expect(mail).to match_body("Dear #{manager.first_name},")
        expect(mail).to match_body('Members have been either added to or removed from the ' \
                                   '20 Minutes into the Future collection.')
      end
    end

    context 'when notify managers and reviewers on participant changes is disabled' do
      before do
        ActionMailer::Base.deliveries.clear
      end

      it 'does not render an email' do
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end

  describe '#first_version_created_email' do
    let(:collection) do
      create(:collection, :with_druid, user:, title: '20 Minutes into the Future')
    end
    let(:mail) { described_class.with(collection:).first_version_created_email }

    it 'renders the headers' do
      expect(mail.subject).to eq 'A new collection has been created'
      expect(mail.to).to eq ['h2-administrators@lists.stanford.edu']
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail).to match_body('Dear Administrator,')
      expect(mail).to match_body('The following new collection has been created in H3')
    end
  end
end
