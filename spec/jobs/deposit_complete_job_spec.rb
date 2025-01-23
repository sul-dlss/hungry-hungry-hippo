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
    allow(ModelSync::Work).to receive(:call)
    allow(ModelSync::Collection).to receive(:call)
    allow(Settings.notifications).to receive(:enabled).and_return(false)
  end

  context 'when a work' do
    let(:object) { create(:work, druid: druid_fixture, deposit_state: 'accessioning') }

    it 'marks the accessioning as complete' do
      expect { job.work(message) }.to change {
        object.reload.deposit_state
      }.from('accessioning').to('deposit_not_in_progress')
    end

    it 'syncs and returns ack' do
      expect(job.work(message)).to eq(:ack)
      expect(ModelSync::Work).to have_received(:call).with(work: object, cocina_object: dro_fixture, raise: false)
    end
  end

  context 'when a collection' do
    let(:object) { create(:collection, druid: collection_druid_fixture, deposit_state: 'accessioning') }

    it 'marks the accessioning as complete' do
      expect { job.work(message) }.to change {
        object.reload.deposit_state
      }.from('accessioning').to('deposit_not_in_progress')
    end

    it 'syncs and returns ack' do
      expect(job.work(message)).to eq(:ack)
      expect(ModelSync::Collection).to have_received(:call).with(collection: object, cocina_object: collection_fixture)
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
