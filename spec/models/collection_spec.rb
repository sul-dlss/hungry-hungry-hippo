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
end
