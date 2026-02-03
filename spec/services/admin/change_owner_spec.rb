# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ChangeOwner do
  let(:work_form) { WorkForm.new }
  let(:work) { create(:work, user: current_user, collection:) }
  let(:collection) { create(:collection, user: current_user) }
  let(:current_user) { create(:user) }
  let(:user) { create(:user) }
  let(:admin_user) { create(:user) }
  let(:ahoy_visit) { Ahoy::Visit.new }

  before do
    allow(DepositWorkJob).to receive(:perform_later)
    allow(Notifier).to receive(:publish)
    allow(Sdr::Repository).to receive(:status).and_return(version_status)
    allow(Sdr::Event).to receive(:create)
  end

  context 'when the work is not open' do
    let(:version_status) { build(:version_status) }

    it 'changes the owner of the work with deposit' do
      expect(work.user).to eq(current_user)
      described_class.call(work_form:, work:, user:, admin_user:, ahoy_visit:)

      expect(work.user).to eq(user)
      expect(work_form.collection_druid).to eq(collection.druid)
      expect(collection.depositors).to include(work.user)
      expect(work.reload.deposit_registering_or_updating?).to be(true)
      description = "Changed owner from #{current_user.sunetid} to #{user.sunetid}"
      expect(Sdr::Event).to have_received(:create).with(druid: work.druid,
                                                        type: 'h3_owner_changed',
                                                        data: {
                                                          who: admin_user.sunetid,
                                                          description:
                                                        })

      expect(DepositWorkJob).to have_received(:perform_later).with(work:, work_form:, deposit: true,
                                                                   request_review: false, current_user: user,
                                                                   ahoy_visit:)
      expect(Notifier).to have_received(:publish).with(Notifier::OWNERSHIP_CHANGED, work:, user:)
      expect(Notifier).to have_received(:publish).with(Notifier::DEPOSITOR_ADDED, collection:, user:)
    end
  end

  context 'when the work is open' do
    let(:version_status) { build(:draft_version_status) }

    it 'moves a work to another collection with deposit' do
      expect(work.user).to eq(current_user)
      described_class.call(work_form:, work:, user:, admin_user:, ahoy_visit:)

      expect(DepositWorkJob).to have_received(:perform_later).with(work:, work_form:, deposit: false,
                                                                   request_review: false, current_user: user,
                                                                   ahoy_visit:)
    end
  end
end
