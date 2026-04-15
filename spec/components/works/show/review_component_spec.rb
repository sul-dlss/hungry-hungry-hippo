# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::ReviewComponent, type: :component do
  let(:reviewer) { create(:user) }
  let(:collection) { create(:collection, reviewers: [reviewer]) }
  let(:work) { create(:work, collection:, review_state:, deposit_state:, druid: druid_fixture) }
  let(:review_state) { 'pending_review' }
  let(:deposit_state) { 'deposit_not_in_progress' }
  let(:review_form) { ReviewForm.new }

  before do
    allow(vc_test_controller).to receive(:current_user).and_return(reviewer)
    allow(Current).to receive_messages(groups: [], user: reviewer)
  end

  context 'when work is pending review and not depositing' do
    it 'renders review controls' do
      with_request_url "/works/#{druid_fixture}" do
        render_inline(described_class.new(work:, review_form:))
      end

      expect(page).to have_css('.alert')
    end
  end

  context 'when work is pending review but deposit is in progress' do
    let(:deposit_state) { 'deposit_registering_or_updating' }

    it 'does not render review controls' do
      render_inline(described_class.new(work:, review_form:))

      expect(page).to have_no_css('.alert')
    end
  end

  context 'when work is pending review but accessioning' do
    let(:deposit_state) { 'accessioning' }

    it 'does not render review controls' do
      render_inline(described_class.new(work:, review_form:))

      expect(page).to have_no_css('.alert')
    end
  end

  context 'when user cannot review' do
    before do
      allow(vc_test_controller).to receive(:current_user).and_return(create(:user))
      allow(Current).to receive(:user).and_return(create(:user))
    end

    it 'does not render review controls' do
      render_inline(described_class.new(work:, review_form:))

      expect(page).to have_no_css('.alert')
    end
  end

  context 'when work is not pending review' do
    let(:review_state) { 'review_not_in_progress' }

    it 'does not render review controls' do
      render_inline(described_class.new(work:, review_form:))

      expect(page).to have_no_css('.alert')
    end
  end
end
