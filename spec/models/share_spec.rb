# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Share do
  let(:share) { create(:share) }
  let(:work) { share.work }

  before do
    allow(Notifier).to receive(:publish)
  end

  describe '.create' do
    it 'sends a notification' do
      expect(Notifier).to have_received(:publish).with(Notifier::SHARE_ADDED, work:, share:)
    end
  end

  describe '.save' do
    it 'does not send a notification when saving or updating' do
      # save a change
      share.permission = Share::VIEW_EDIT_PERMISSION
      share.save

      # update it
      share.update(permission: Share::VIEW_EDIT_DEPOSIT_PERMISSION)

      # still only a single notification when it was first created
      expect(Notifier).to have_received(:publish).with(Notifier::SHARE_ADDED, work:, share:).once
    end
  end
end
