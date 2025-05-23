# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositCompleteJob do
  include WorkMappingFixtures
  include CollectionMappingFixtures

  subject(:job) { described_class.new }

  let(:message) { { druid: object.druid }.to_json }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid: druid_fixture).and_return(dro_fixture)
    allow(Sdr::Repository).to receive(:find).with(druid: collection_druid_fixture).and_return(collection_fixture)
    allow(WorkModelSynchronizer).to receive(:call)
    allow(CollectionModelSynchronizer).to receive(:call)
    allow(Turbo::StreamsChannel).to receive(:broadcast_refresh_to)
  end

  context 'when a work' do
    let(:object) { create(:work, druid: druid_fixture, deposit_state: 'accessioning') }

    it 'marks the accessioning as complete' do
      expect { job.work(message) }.to change {
        object.reload.deposit_state
      }.from('accessioning').to('deposit_not_in_progress')
    end

    it 'syncs, refreshes, and returns ack' do
      expect(job.work(message)).to eq(:ack)
      expect(WorkModelSynchronizer).to have_received(:call).with(work: object, cocina_object: dro_fixture, raise: false)
      expect(Turbo::StreamsChannel).to have_received(:broadcast_refresh_to).with(object)
    end
  end

  context 'when a collection' do
    let(:object) { create(:collection, druid: collection_druid_fixture, deposit_state: 'accessioning') }

    it 'marks the accessioning as complete' do
      expect { job.work(message) }.to change {
        object.reload.deposit_state
      }.from('accessioning').to('deposit_not_in_progress')
    end

    it 'syncs, refreshes, and returns ack' do
      expect(job.work(message)).to eq(:ack)
      expect(CollectionModelSynchronizer).to have_received(:call)
        .with(collection: object, cocina_object: collection_fixture)
      expect(Turbo::StreamsChannel).to have_received(:broadcast_refresh_to).with(object)
    end
  end

  context 'when not accessioning' do
    let(:object) { create(:work, druid: druid_fixture) }

    it 'does not change the deposit state' do
      expect { job.work(message) }.not_to(change { object.reload.deposit_state })
    end

    it 'returns ack' do
      expect(job.work(message)).to eq(:ack)
    end
  end
end
