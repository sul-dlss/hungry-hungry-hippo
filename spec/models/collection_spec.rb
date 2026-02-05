# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection do
  let(:user) { create(:user) }
  let(:collection) { create(:collection, title: collection_title_fixture, user:) }

  before do
    allow(Notifier).to receive(:publish)
  end

  context 'when adding a manager' do
    it 'sends only a MANAGER_ADDED event' do
      collection.managers << user
      expect(Notifier).to have_received(:publish).once.with(Notifier::MANAGER_ADDED, collection:, user:)
    end
  end

  context 'when adding a depositor' do
    it 'sends only a DEPOSITOR_ADDED event' do
      collection.depositors << user
      expect(Notifier).to have_received(:publish).once.with(Notifier::DEPOSITOR_ADDED, collection:, user:)
    end
  end

  describe '.deposit_persist_complete!' do
    let(:collection) { create(:collection, deposit_state: 'deposit_registering_or_updating') }

    it 'changes state and sends a notification' do
      expect do
        collection.deposit_persist_complete!
      end.to change(collection, :deposit_state).from('deposit_registering_or_updating').to('deposit_not_in_progress')
      expect(Notifier).to have_received(:publish).with(Notifier::DEPOSIT_PERSIST_COMPLETE, object: collection)
    end
  end

  context 'when adding a reviewer' do
    it 'sends only a REVIEWER_ADDED event' do
      collection.reviewers << user
      expect(Notifier).to have_received(:publish).once.with(Notifier::REVIEWER_ADDED, collection:, user:)
    end
  end

  context 'when removing a manager' do
    before do
      collection.managers << user
    end

    it 'sends only a MANAGER_REMOVED event' do
      collection.managers.destroy(user)
      expect(Notifier).to have_received(:publish).once.with(Notifier::MANAGER_REMOVED, collection:, user:)
    end
  end

  context 'when removing a depositor' do
    before do
      collection.depositors << user
    end

    it 'sends only a DEPOSITOR_REMOVED event' do
      collection.depositors.destroy(user)
      expect(Notifier).to have_received(:publish).once.with(Notifier::DEPOSITOR_REMOVED, collection:, user:)
    end
  end

  context 'when removing a reviewer' do
    before do
      collection.reviewers << user
    end

    it 'sends only a REVIEWER_REMOVED event' do
      collection.reviewers.destroy(user)
      expect(Notifier).to have_received(:publish).once.with(Notifier::REVIEWER_REMOVED, collection:, user:)
    end
  end

  describe '#max_release_date' do
    subject(:max_release_date) { collection.max_release_date }

    let(:collection) { create(:collection, title: collection_title_fixture, user:, release_duration:) }

    context 'when release duration is six months' do
      let(:release_duration) { :six_months }

      it { is_expected.to eq(Time.zone.today + 6.months) }
    end

    context 'when release duration is one year' do
      let(:release_duration) { :one_year }

      it { is_expected.to eq(Time.zone.today + 1.year) }
    end

    context 'when release duration is two years' do
      let(:release_duration) { :two_years }

      it { is_expected.to eq(Time.zone.today + 2.years) }
    end

    context 'when release duration is three years' do
      let(:release_duration) { :three_years }

      it { is_expected.to eq(Time.zone.today + 3.years) }
    end
  end

  describe '#accession!' do
    let(:collection) { create(:collection, deposit_state: 'deposit_registering_or_updating') }
    let(:user) { create(:user) }

    before do
      Current.user = user
    end

    it 'changes state and sends a notification' do
      expect { collection.accession! }.to change(collection, :deposit_state)
        .from('deposit_registering_or_updating')
        .to('accessioning')
      expect(Notifier).to have_received(:publish).once.with(Notifier::ACCESSIONING_STARTED, object: collection,
                                                                                            current_user: user)
    end
  end

  describe '#accession_complete!' do
    let(:collection) { create(:collection, deposit_state: 'accessioning') }

    it 'changes state and sends a notification' do
      expect { collection.accession_complete! }.to change(collection, :deposit_state)
        .from('accessioning')
        .to('deposit_not_in_progress')
      expect(Notifier).to have_received(:publish).once.with(Notifier::ACCESSIONING_COMPLETE, object: collection)
    end
  end

  describe 'workflow settings validation' do
    context 'when review enabled and github deposit enabled' do
      let(:collection) { FactoryBot.build(:collection, review_enabled: true, github_deposit_enabled: true) } # rubocop:disable FactoryBot/SyntaxMethods

      it 'is not valid' do
        expect(collection).not_to be_valid
        expect(collection.errors[:base]).to include('GitHub deposit cannot be enabled when review workflow is enabled')
      end
    end

    context 'when review enabled and article deposit enabled' do
      let(:collection) { FactoryBot.build(:collection, review_enabled: true, article_deposit_enabled: true) } # rubocop:disable FactoryBot/SyntaxMethods

      it 'is not valid' do
        expect(collection).not_to be_valid
        expect(collection.errors[:base]).to include('Article deposit cannot be enabled when review workflow is enabled')
      end
    end
  end
end
