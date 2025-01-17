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

    before do
      # Not your work
      create(:work, collection: create(:collection, user: owning_user))
    end

    it 'returns the works that are part of the your collections' do
      expect(user.your_works).to contain_exactly(managed_work, depositor_work, reviewed_work)
    end
  end
end
