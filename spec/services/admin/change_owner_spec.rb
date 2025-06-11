# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ChangeOwner do
  let(:work_form) { WorkForm.new }
  let(:work) { create(:work, user: current_user, collection:) }
  let(:collection) { create(:collection, user: current_user) }
  let(:current_user) { create(:user) }
  let(:next_user) { create(:user) }

  before do
    allow(DepositWorkJob).to receive(:perform_later)
    Current.user = current_user
  end

  context 'when the work is not open' do
    let(:version_status) { build(:version_status) }

    it 'changes the owner of the work with deposit' do
      expect(work.user).to eq(current_user)
      described_class.call(work_form:, work:, owner: next_user, version_status:)

      expect(work.user).to eq(next_user)
      expect(work_form.collection_druid).to eq(collection.druid)
      expect(collection.depositors).to include(work.user)
      expect(work.reload.deposit_registering_or_updating?).to be(true)

      expect(DepositWorkJob).to have_received(:perform_later).with(work:, work_form:, deposit: true,
                                                                   request_review: false, current_user: next_user)
    end
  end

  context 'when the work is open' do
    let(:version_status) { build(:draft_version_status) }

    it 'moves a work to another collection with deposit' do
      expect(work.user).to eq(current_user)
      described_class.call(work_form:, work:, owner: next_user, version_status:)

      expect(DepositWorkJob).to have_received(:perform_later).with(work:, work_form:, deposit: false,
                                                                   request_review: false, current_user: next_user)
    end
  end
end
