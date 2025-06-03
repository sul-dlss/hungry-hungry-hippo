# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Work do
  let(:user) { instance_double(User) }

  before do
    allow(Notifier).to receive(:publish)
    allow(Current).to receive(:user).and_return(user)
  end

  describe '.request_review!' do
    let(:work) { create(:work, review_state: 'review_not_in_progress') }

    it 'changes state and sends a notification' do
      expect { work.request_review! }.to change(work, :review_state).from('review_not_in_progress').to('pending_review')
      expect(Notifier).to have_received(:publish).with(Notifier::REVIEW_REQUESTED, work:, current_user: user)
    end
  end

  describe '.approve!' do
    let(:work) { create(:work, review_state: 'pending_review') }

    it 'changes state and sends a notification' do
      expect { work.approve! }.to change(work, :review_state).from('pending_review').to('review_not_in_progress')
      expect(Notifier).to have_received(:publish).with(Notifier::REVIEW_APPROVED, work:, current_user: user)
    end
  end

  describe '.reject!' do
    let(:work) { create(:work, review_state: 'pending_review') }

    it 'changes state and sends a notification' do
      expect { work.reject! }.to change(work, :review_state).from('pending_review').to('rejected_review')
      expect(Notifier).to have_received(:publish).with(Notifier::REVIEW_REJECTED, work:, current_user: user)
    end
  end

  describe '.accession_complete!' do
    let(:work) { create(:work, deposit_state: 'accessioning') }

    it 'changes state and sends a notification' do
      expect do
        work.accession_complete!
      end.to change(work, :deposit_state).from('accessioning').to('deposit_not_in_progress')
      expect(Notifier).to have_received(:publish).with(Notifier::ACCESSIONING_COMPLETE, object: work)
    end
  end
end
