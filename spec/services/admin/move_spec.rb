# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Move do
  let(:work_form) { WorkForm.new }
  let(:work) { create(:work) }
  let(:collection) { create(:collection) }
  let(:current_user) { create(:user) }
  let(:ahoy_visit) { Ahoy::Visit.new }

  before do
    allow(DepositWorkJob).to receive(:perform_later)
    Current.user = current_user
  end

  context 'when the work is not open' do
    let(:version_status) { build(:version_status) }

    it 'moves a work to another collection with deposit' do
      described_class.call(work_form:, work:, collection:, version_status:, ahoy_visit:)

      expect(work_form.collection_druid).to eq(collection.druid)
      expect(collection.depositors).to include(work.user)
      expect(work.reload.deposit_registering_or_updating?).to be(true)

      expect(DepositWorkJob).to have_received(:perform_later).with(work:, work_form:, deposit: true,
                                                                   request_review: false, current_user:,
                                                                   ahoy_visit:)
    end
  end

  context 'when the work is open' do
    let(:version_status) { build(:draft_version_status) }

    it 'moves a work to another collection with deposit' do
      described_class.call(work_form:, work:, collection:, version_status:, ahoy_visit:)

      expect(DepositWorkJob).to have_received(:perform_later).with(work:, work_form:, deposit: false,
                                                                   request_review: false, current_user:,
                                                                   ahoy_visit:)
    end
  end
end
