# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkSortService do
  let(:collection) { create(:collection) }
  let(:work) { create(:work, :with_druid, user:, title: 'AAA Title', updated_at: 3.days.ago, collection:) }
  let(:work2) { create(:work, :with_druid, user: user2, title: 'MMM Title', updated_at: 2.days.ago, collection:) }
  let(:work3) { create(:work, :with_druid, user:, title: 'ZZZ Title', updated_at: 1.day.ago, collection:) }
  let(:works) do
    collection.works.joins(:user)
  end
  # New version in draft
  let(:version_status) do
    build(:version_status)
  end
  # Deposited
  let(:version_status2) do
    build(:draft_version_status)
  end
  # Deposit in progress
  let(:version_status3) do
    build(:accessioning_version_status)
  end
  let(:user) { create(:user, name: 'Amelia') }
  let(:user2) { create(:user, name: 'Zoe') }

  before do
    allow(Sdr::Repository).to receive(:statuses).and_return(
      {
        work.druid => version_status,
        work2.druid => version_status2,
        work3.druid => version_status3
      }
    )
  end

  describe '.call' do
    context 'when no sort order provided' do
      let(:sort_by) { 'works.title asc' }

      it 'orders by title' do
        presenters = described_class.call(works:, sort_by:)
        expect(presenters.first.work).to have_attributes(title: 'AAA Title')
        expect(presenters.last.work).to have_attributes(title: 'ZZZ Title')
      end
    end

    context 'when sorting by title descending' do
      let(:sort_by) { 'works.title desc' }

      it 'orders by title descending' do
        presenters = described_class.call(works:, sort_by:)
        expect(presenters.first.work).to have_attributes(title: 'ZZZ Title')
        expect(presenters.last.work).to have_attributes(title: 'AAA Title')
      end
    end

    context 'when sorting by owner ascending' do
      let(:sort_by) { 'users.name asc' }

      before do
        work2.update(user: user2)
      end

      it 'orders by owner name ascending' do
        presenters = described_class.call(works:, sort_by:)
        expect(presenters.first.work.user.name).to eq('Amelia')
        expect(presenters.last.work.user.name).to eq('Zoe')
      end
    end

    context 'when sorting by owner descending' do
      let(:sort_by) { 'users.name desc' }

      it 'orders by owner name descending' do
        presenters = described_class.call(works:, sort_by:)
        expect(presenters.first.work.user.name).to eq('Zoe')
        expect(presenters.last.work.user.name).to eq('Amelia')
      end
    end

    context 'when sorting by status ascending' do
      let(:sort_by) { 'status asc' }

      it 'orders by status message ascending' do
        presenters = described_class.call(works:, sort_by:)
        expect(presenters.first.status_message).to eq('Deposited')
        expect(presenters.last.status_message).to eq('New version in draft')
      end
    end

    context 'when sorting by status descending' do
      let(:sort_by) { 'status desc' }

      it 'orders by status message descending' do
        presenters = described_class.call(works:, sort_by:)
        expect(presenters.first.status_message).to eq('New version in draft')
        expect(presenters.last.status_message).to eq('Deposited')
      end
    end

    context 'when sorting by date modified ascending' do
      let(:sort_by) { 'works.object_updated_at asc' }

      it 'orders by updated_at ascending' do
        presenters = described_class.call(works:, sort_by:)
        expect(presenters.first.work.title).to eq('AAA Title')
        expect(presenters.last.work.title).to eq('ZZZ Title')
      end
    end

    context 'when sorting by date modified descending' do
      let(:sort_by) { 'works.object_updated_at desc' }

      it 'orders by updated_at descending' do
        presenters = described_class.call(works:, sort_by:)
        expect(presenters.first.work.title).to eq('ZZZ Title')
        expect(presenters.last.work.title).to eq('AAA Title')
      end
    end
  end
end
