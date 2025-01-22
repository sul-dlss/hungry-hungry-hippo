# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::SubmitComponent, type: :component do
  let(:form_id) { 'new_work' }
  let(:user) { create(:user) }
  let(:reviewer) { create(:user) }
  let(:collection) { create(:collection, review_enabled:, reviewers: [reviewer]) }
  let(:work) { create(:work, user:, collection:) }
  let(:review_enabled) { true }

  before do
    allow(Current).to receive(:groups).and_return([])
  end

  context 'when work is nil (for a create)' do
    let(:required) { false }

    it 'renders the submit' do
      render_inline(described_class.new(form_id:, work: nil, collection:))

      expect(page).to have_button('Submit for review')
    end
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
end
