# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection do
  let(:user) { create(:user) }

  before do
    allow(Notifier).to receive(:publish)
  end

  describe 'add user to collection' do
    it 'adds the collection owner to the collection' do
      collection = described_class.create(title: collection_title_fixture, user:)
      expect(collection.managers).to eq([user])
      expect(Notifier).to have_received(:publish).with(Notifier::MANAGER_ADDED, collection:, user:)
    end

    context 'when collection owner is already a manager' do
      it 'does not add the collection owner to the collection' do
        collection = described_class.create(title: collection_title_fixture, user:, managers: [user])
        expect(collection.managers).to eq([user])
      end
    end

    context 'when no collection owner' do
      it 'does not add the collection owner to the collection' do
        collection = described_class.create(title: collection_title_fixture)
        expect(collection.managers).to be_empty
      end
    end

    context 'when a collection owner id is provided' do
      it 'adds the collection owner to the collection' do
        collection = described_class.create(title: collection_title_fixture, user_id: user.id)
        expect(collection.managers).to eq([user])
      end
    end
  end

  describe 'Add depositor to collection' do
    let(:collection) { described_class.create(title: collection_title_fixture, user:) }

    it 'sends an event' do
      collection.depositors << user
      expect(Notifier).to have_received(:publish).with(Notifier::DEPOSITOR_ADDED, collection:,
                                                                                  user:)
    end
  end

  describe 'Add reviewer to collection' do
    let(:collection) { described_class.create(title: collection_title_fixture, user:) }

    it 'sends an event' do
      collection.reviewers << user
      expect(Notifier).to have_received(:publish).with(Notifier::REVIEWER_ADDED, collection:,
                                                                                 user:)
    end
  end

  describe '.accession_complete!' do
    let(:collection) { create(:collection, deposit_state: 'accessioning') }

    it 'changes state and sends a notification' do
      expect do
        collection.accession_complete!
      end.to change(collection, :deposit_state).from('accessioning').to('deposit_none')
      expect(Notifier).to have_received(:publish).with(Notifier::ACCESSIONING_COMPLETE, object: collection)
    end
  end
end
