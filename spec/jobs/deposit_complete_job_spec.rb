# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositCompleteJob do
  subject(:job) { described_class.new }

  let(:message) { { druid: object.druid }.to_json }

  context 'when a work' do
    let(:object) { create(:work, :with_druid, deposit_state: 'accessioning') }

    it 'marks the accessioning as complete' do
      expect { job.work(message) }.to change {
        object.reload.deposit_state
      }.from('accessioning').to('deposit_none')
    end

    it 'returns ack' do
      expect(job.work(message)).to eq(:ack)
    end
  end

  context 'when a collection' do
    let(:object) { create(:collection, :with_druid, deposit_state: 'accessioning') }

    it 'marks the accessioning as complete' do
      expect { job.work(message) }.to change {
        object.reload.deposit_state
      }.from('accessioning').to('deposit_none')
    end

    it 'returns ack' do
      expect(job.work(message)).to eq(:ack)
    end
  end

  context 'when not accessioning' do
    let(:object) { create(:work, :with_druid) }

    it 'does not change the deposit state' do
      expect { job.work(message) }.not_to(change { object.reload.deposit_state })
    end

    it 'returns ack' do
      expect(job.work(message)).to eq(:ack)
    end
  end
end
