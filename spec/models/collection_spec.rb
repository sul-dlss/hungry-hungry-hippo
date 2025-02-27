# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection do
  let(:user) { create(:user) }
  let(:collection) { described_class.create(title: collection_title_fixture, user:) }

  before do
    allow(Notifier).to receive(:publish)
  end

  describe 'Add participants to a collection' do
    context 'when adding a manager to collection' do
      it 'only sends a MANAGER_ADDED event' do
        collection.managers << user
        expect(Notifier).to have_received(:publish).with(Notifier::MANAGER_ADDED, collection:,
                                                                                  user:)
        expect(Notifier).not_to have_received(:publish).with(Notifier::MANAGER_REMOVED)
      end
    end

    context 'when adding a depositor to collection' do
      it 'only sends a DEPOSITOR_ADDED event' do
        collection.depositors << user
        expect(Notifier).to have_received(:publish).with(Notifier::DEPOSITOR_ADDED, collection:,
                                                                                    user:)
        expect(Notifier).not_to have_received(:publish).with(Notifier::DEPOSITOR_REMOVED)
      end
    end

    context 'when adding a reviewer to collection' do
      it 'only sends a REVIEWER_ADDED event' do
        collection.reviewers << user
        expect(Notifier).to have_received(:publish).with(Notifier::REVIEWER_ADDED, collection:,
                                                                                   user:)
        expect(Notifier).not_to have_received(:publish).with(Notifier::REVIEWER_REMOVED)
      end
    end
  end

  describe 'Remove participants from a collection' do
    context 'when removing a manager to collection' do
      let(:manager) { create(:user) }

      before do
        collection.managers << manager
      end

      it 'only sends a MANAGER_REMOVED event' do
        collection.managers.destroy(manager)
        expect(Notifier).to have_received(:publish).with(Notifier::MANAGER_REMOVED, collection:,
                                                                                    user: manager)
        expect(Notifier).not_to have_received(:publish).with(Notifier::MANAGER_ADDED, collection:)
      end
    end

    context 'when removing a depositor from collection' do
      let(:depositor) { create(:user) }

      before do
        collection.depositors << depositor
      end

      it 'only sends a DEPOSITOR_REMOVED event' do
        collection.depositors.destroy(depositor)
        expect(Notifier).to have_received(:publish).with(Notifier::DEPOSITOR_REMOVED, collection:,
                                                                                      user: depositor)
        expect(Notifier).not_to have_received(:publish).with(Notifier::DEPOSITOR_ADDED, collection:)
      end
    end

    context 'when removing a reviewer from collection' do
      let(:reviewer) { create(:user) }

      before do
        collection.reviewers << reviewer
      end

      it 'only sends a REVIEWER_REMOVED event' do
        collection.reviewers.destroy(reviewer)
        expect(Notifier).to have_received(:publish).with(Notifier::REVIEWER_REMOVED, collection:,
                                                                                     user: reviewer)
        expect(Notifier).not_to have_received(:publish).with(Notifier::REVIEWER_ADDED, collection:)
      end
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

  describe '.accession_complete!' do
    let(:collection) { create(:collection, deposit_state: 'accessioning') }

    it 'changes state and sends a notification' do
      expect do
        collection.accession_complete!
      end.to change(collection, :deposit_state).from('accessioning').to('deposit_not_in_progress')
      expect(Notifier).to have_received(:publish).with(Notifier::ACCESSIONING_COMPLETE, object: collection)
    end
  end
end
