# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection do
  let(:user) { create(:user) }

  before do
    allow(Notifier).to receive(:publish)
  end

  describe 'Add manager to collection' do
    let(:collection) { described_class.create(title: collection_title_fixture, user:) }

    it 'sends an event' do
      collection.managers << user
      expect(Notifier).to have_received(:publish).with(Notifier::MANAGER_ADDED, collection:,
                                                                                user:)
      expect(Notifier).not_to have_received(:publish).with(Notifier::MANAGER_REMOVED)
    end
  end

  describe 'Add depositor to collection' do
    let(:collection) { described_class.create(title: collection_title_fixture, user:) }

    it 'sends an event' do
      collection.depositors << user
      expect(Notifier).to have_received(:publish).with(Notifier::DEPOSITOR_ADDED, collection:,
                                                                                  user:)
      expect(Notifier).not_to have_received(:publish).with(Notifier::DEPOSITOR_REMOVED)
    end
  end

  describe 'Add reviewer to collection' do
    let(:collection) { described_class.create(title: collection_title_fixture, user:) }

    it 'sends an event' do
      collection.reviewers << user
      expect(Notifier).to have_received(:publish).with(Notifier::REVIEWER_ADDED, collection:,
                                                                                 user:)
      expect(Notifier).not_to have_received(:publish).with(Notifier::REVIEWER_REMOVED)
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
