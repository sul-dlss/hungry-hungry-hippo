# frozen_string_literal: true

require 'rails_helper'
RSpec.describe WorkPolicy do
  let(:owner) { create(:user) }
  let(:plain_old_user) { create(:user) }
  let(:reviewer) { create(:user) }
  let(:manager) { create(:user) }
  let(:shared_user) { create(:user) }
  let(:collection_owner) { create(:user) }

  let!(:owned_work) { create(:work, user: owner, collection:, title: 'owned') }
  let(:shared_work) { create(:work, collection:, title: 'shared') }

  let(:collection) { create(:collection, reviewers: [reviewer], managers: [manager], user: collection_owner) }
  let(:permission) { 'view' }

  before do
    Current.groups = []
    create(:share, user: shared_user, work: shared_work, permission:)
  end

  describe '.show?' do
    subject { policy.apply(:show?) }

    let(:policy) { described_class.new(work, user:) }
    let(:work) { owned_work }

    context 'when owner of the work' do
      let(:user) { owner }

      it { is_expected.to be true }
    end

    context 'when reviewer' do
      let(:user) { reviewer }

      it { is_expected.to be true }
    end

    context 'when plain-old user' do
      let(:user) { plain_old_user }

      it { is_expected.to be false }
    end

    context 'when user with view permissions' do
      let(:user) { shared_user }
      let(:work) { shared_work }

      it { is_expected.to be true }
    end

    context 'when user with view/edit permissions' do
      let(:user) { shared_user }
      let(:permission) { 'edit' }
      let(:work) { shared_work }

      it { is_expected.to be true }
    end

    context 'when user with view/edit/deposit permissions' do
      let(:user) { shared_user }
      let(:permission) { 'deposit' }
      let(:work) { shared_work }

      it { is_expected.to be true }
    end
  end

  describe '.edit?/.update?' do
    subject { policy.apply(:edit?) }

    let(:policy) { described_class.new(work, user:) }
    let(:work) { owned_work }

    context 'when owner of the work' do
      let(:user) { owner }

      it { is_expected.to be true }
    end

    context 'when reviewer' do
      let(:user) { reviewer }

      it { is_expected.to be false }
    end

    context 'when manager' do
      let(:user) { manager }

      it { is_expected.to be true }
    end

    context 'when collection owner' do
      let(:user) { collection_owner }

      it { is_expected.to be true }
    end

    context 'when plain-old user' do
      let(:user) { plain_old_user }

      it { is_expected.to be false }
    end

    context 'when user with view permissions' do
      let(:user) { shared_user }
      let(:permission) { 'view' }
      let(:work) { shared_work }

      it { is_expected.to be false }
    end

    context 'when user with view/edit permissions' do
      let(:user) { shared_user }
      let(:permission) { 'edit' }
      let(:work) { shared_work }

      it { is_expected.to be true }
    end

    context 'when user with view/edit/deposit permissions' do
      let(:user) { shared_user }
      let(:permission) { 'deposit' }
      let(:work) { shared_work }

      it { is_expected.to be true }
    end
  end

  describe '.deposit?' do
    subject { policy.apply(:deposit?) }

    let(:policy) { described_class.new(work, user:) }
    let(:work) { owned_work }

    context 'when owner of the work' do
      let(:user) { owner }

      it { is_expected.to be true }
    end

    context 'when reviewer' do
      let(:user) { reviewer }

      it { is_expected.to be true }
    end

    context 'when manager' do
      let(:user) { manager }

      it { is_expected.to be true }
    end

    context 'when collection owner' do
      let(:user) { collection_owner }

      it { is_expected.to be true }
    end

    context 'when plain-old user' do
      let(:user) { plain_old_user }

      it { is_expected.to be false }
    end

    context 'when user with view permissions' do
      let(:user) { shared_user }
      let(:permission) { 'view' }
      let(:work) { shared_work }

      it { is_expected.to be false }
    end

    context 'when user with view/edit permissions' do
      let(:user) { shared_user }
      let(:permission) { 'edit' }
      let(:work) { shared_work }

      it { is_expected.to be false }
    end

    context 'when user with view/edit/deposit permissions' do
      let(:user) { shared_user }
      let(:permission) { 'deposit' }
      let(:work) { shared_work }

      it { is_expected.to be true }
    end
  end

  describe '.destroy?' do
    subject { policy.apply(:destroy?) }

    let(:policy) { described_class.new(work, user:) }
    let(:work) { owned_work }

    context 'when owner of the work' do
      let(:user) { owner }

      it { is_expected.to be true }
    end

    context 'when reviewer' do
      let(:user) { reviewer }

      it { is_expected.to be false }
    end

    context 'when manager' do
      let(:user) { manager }

      it { is_expected.to be true }
    end

    context 'when collection owner' do
      let(:user) { collection_owner }

      it { is_expected.to be true }
    end

    context 'when plain-old user' do
      let(:user) { plain_old_user }

      it { is_expected.to be false }
    end

    context 'when user with view/edit/deposit permissions' do
      let(:user) { shared_user }
      let(:permission) { 'deposit' }
      let(:work) { shared_work }

      it { is_expected.to be false }
    end
  end

  describe 'collection scope' do
    subject do
      policy.apply_scope(target, name: :collection, type: :active_record_relation, scope_options: { collection: }).to_a
    end

    let!(:unowned_work) { create(:work, collection:, title: 'unowned') }

    let(:policy) { described_class.new(user:) }

    let(:target) do
      collection.works.order(title: :asc)
    end

    context 'when owner' do
      let(:user) { owner }

      it { is_expected.to eq([owned_work]) }
    end

    context 'when reviewer' do
      let(:user) { reviewer }

      it { is_expected.to eq([owned_work, shared_work, unowned_work]) }
    end

    context 'when manager' do
      let(:user) { manager }

      it { is_expected.to eq([owned_work, shared_work, unowned_work]) }
    end

    context 'when user with view permissions' do
      let(:user) { shared_user }

      it { is_expected.to eq([shared_work]) }
    end

    context 'when user with view/edit permissions' do
      let(:user) { shared_user }
      let(:permission) { 'edit' }

      it { is_expected.to eq([shared_work]) }
    end

    context 'when user with view/edit/deposit permissions' do
      let(:user) { shared_user }
      let(:permission) { 'deposit' }

      it { is_expected.to eq([shared_work]) }
    end

    context 'when there are shares for the work in the collection' do
      let(:user) { owner }
      let!(:shared_work) { create(:work, user: owner, collection:, title: 'shared') }
      let(:permission) { 'deposit' }

      before do
        create(:share, user: plain_old_user, work: shared_work, permission:)
      end

      it { is_expected.to eq([owned_work, shared_work]) }
    end
  end
end
