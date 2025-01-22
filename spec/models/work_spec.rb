# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Work do
  before do
    allow(Notifier).to receive(:publish)
  end

  describe '.request_review!' do
    let(:work) { create(:work, review_state: 'none_review') }

    it 'changes state and sends a notification' do
      expect { work.request_review! }.to change(work, :review_state).from('none_review').to('pending_review')
      expect(Notifier).to have_received(:publish).with(Notifier::REVIEW_REQUESTED, work:)
    end
  end

  describe '.approve!' do
    let(:work) { create(:work, review_state: 'pending_review') }

    it 'changes state and sends a notification' do
      expect { work.approve! }.to change(work, :review_state).from('pending_review').to('none_review')
      expect(Notifier).to have_received(:publish).with(Notifier::REVIEW_APPROVED, work:)
    end
  end

  describe '.reject!' do
    let(:work) { create(:work, review_state: 'pending_review') }

    it 'changes state and sends a notification' do
      expect { work.reject! }.to change(work, :review_state).from('pending_review').to('rejected_review')
      expect(Notifier).to have_received(:publish).with(Notifier::REVIEW_REJECTED, work:)
    end
  end
end
