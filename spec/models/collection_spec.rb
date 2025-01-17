# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection do
  let(:user) { create(:user) }

  describe 'add user to collection' do
    it 'adds the collection owner to the collection' do
      collection = described_class.create(title: collection_title_fixture, user:)
      expect(collection.managers).to eq([user])
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
end
