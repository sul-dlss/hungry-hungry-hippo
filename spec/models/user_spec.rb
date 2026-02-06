# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  let(:user) { create(:user) }
  let(:owning_user) { create(:user) }
  let!(:managed_collection) { create(:collection, user: owning_user, managers: [user]) }
  let!(:depositor_collection) { create(:collection, user: owning_user, depositors: [user]) }
  let!(:reviewed_collection) { create(:collection, user: owning_user, reviewers: [user]) }
  let!(:deduped_collection) do
    create(:collection, user: owning_user, managers: [user], depositors: [user], reviewers: [user])
  end

  describe '.your_collections' do
    before do
      # Not your collection
      create(:collection, user: owning_user)
    end

    it 'returns the collections for which the user is a manager, depositor, or reviewer' do
      expect(user.your_collections).to contain_exactly(managed_collection, depositor_collection, reviewed_collection,
                                                       deduped_collection)
    end
  end

  describe '.your_works' do
    let!(:managed_work) { create(:work, user: owning_user, collection: managed_collection) }
    let!(:depositor_work) { create(:work, user: owning_user, collection: depositor_collection) }
    let!(:reviewed_work) { create(:work, user: owning_user, collection: reviewed_collection) }
    let!(:owned_work) { create(:work, user:) }

    before do
      # Not your work
      create(:work, collection: create(:collection, user: owning_user))
    end

    it 'returns the works that are part of the your collections' do
      expect(user.your_works).to contain_exactly(managed_work, depositor_work, reviewed_work, owned_work)
    end
  end

  describe '.your_pending_review_works' do
    let!(:pending_review_work) do
      create(:work, user: owning_user, collection: reviewed_collection, review_state: :pending_review)
    end
    let!(:pending_managed_review_work) do
      create(:work, user: owning_user, collection: managed_collection, review_state: :pending_review)
    end

    before do
      # Not your pending review work
      create(:work, review_state: :pending_review)
      # Not pending review
      create(:work, user: owning_user, collection: reviewed_collection, review_state: :review_not_in_progress)
    end

    it 'returns the pending review works that are part of the collections for which the user is a reviewer' do
      expect(user.your_pending_review_works).to contain_exactly(pending_review_work, pending_managed_review_work)
    end
  end

  describe '.depositor_for_any_github_deposit_enabled_collections?' do
    context 'when the user is not a depositor or manager for any collections with github_deposit_enabled' do
      it 'returns false' do
        expect(user.depositor_for_any_github_deposit_enabled_collections?).to be false
      end
    end

    context 'when the user is a depositor for a collection with github_deposit_enabled' do
      before do
        create(:collection, github_deposit_enabled: true, depositors: [user])
      end

      it 'returns true' do
        expect(user.depositor_for_any_github_deposit_enabled_collections?).to be true
      end
    end

    context 'when the user is a manager for a collection with github_deposit_enabled' do
      before do
        create(:collection, github_deposit_enabled: true, managers: [user])
      end

      it 'returns true' do
        expect(user.depositor_for_any_github_deposit_enabled_collections?).to be true
      end
    end
  end
end
