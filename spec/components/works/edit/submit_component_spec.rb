# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::SubmitComponent, type: :component do
  let(:form_id) { 'new_work' }
  let(:user) { create(:user) }
  let(:reviewer) { create(:user) }
  let(:share_user) { create(:user) }
  let(:collection) { create(:collection, review_enabled:, reviewers: [reviewer], depositors: [depositor]) }
  let(:depositor) { create(:user) }
  let(:work) { create(:work, user:, collection:) }
  let(:review_enabled) { true }
  let(:permission) { Share::VIEW_PERMISSION }

  before do
    allow(vc_test_controller).to receive(:current_user).and_return(user)
    allow(Current).to receive_messages(groups: [], user:)
    create(:share, user: share_user, work:, permission:)
  end

  context 'when review is not enabled' do
    let(:review_enabled) { false }

    it 'renders the submit' do
      render_inline(described_class.new(form_id:, work:, collection:))

      expect(page).to have_button('Deposit')
    end
  end

  context 'when user is work owner' do
    before do
      allow(vc_test_controller).to receive(:current_user).and_return(user)
      allow(Current).to receive(:groups).and_return([])
    end

    it 'renders the submit' do
      render_inline(described_class.new(form_id:, work:, collection:))

      expect(page).to have_button('Submit for review')
    end
  end

  context 'when user is reviewer' do
    before do
      allow(vc_test_controller).to receive(:current_user).and_return(reviewer)
      allow(Current).to receive(:groups).and_return([])
    end

    it 'renders the submit' do
      render_inline(described_class.new(form_id:, work:, collection:))

      expect(page).to have_button('Deposit')
    end
  end

  context 'when user has deposit share permissions' do
    let(:permission) { Share::VIEW_EDIT_DEPOSIT_PERMISSION }
    let(:review_enabled) { false }

    before do
      allow(vc_test_controller).to receive(:current_user).and_return(share_user)
      allow(Current).to receive(:groups).and_return([])
    end

    it 'renders the submit' do
      render_inline(described_class.new(form_id:, work:, collection:))

      expect(page).to have_button('Deposit')
    end
  end

  context 'when user does not have deposit share permissions' do
    before do
      allow(vc_test_controller).to receive(:current_user).and_return(share_user)
      allow(Current).to receive(:groups).and_return([])
    end

    it 'renders the submit' do
      render_inline(described_class.new(form_id:, work:, collection:))

      expect(page).to have_no_button('Submit for review')
      expect(page).to have_no_button('Deposit')
    end
  end

  context 'when user does not have permissions to review or deposit' do
    before do
      allow(vc_test_controller).to receive(:current_user).and_return(create(:user))
      allow(Current).to receive(:groups).and_return([])
    end

    it 'does not render the submit' do
      render_inline(described_class.new(form_id:, work:, collection:))

      expect(page).to have_no_button('Submit for review')
      expect(page).to have_no_button('Deposit')
    end
  end

  context 'when new work' do
    let(:user) { depositor }
    let(:review_enabled) { false }

    it 'renders the submit' do
      render_inline(described_class.new(form_id:, collection:, work: nil))

      expect(page).to have_button('Deposit')
    end
  end
end
