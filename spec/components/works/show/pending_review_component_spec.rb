# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::PendingReviewComponent, type: :component do
  let(:depositor) { build(:user) }
  let(:viewer) { depositor }
  let(:work) { instance_double(Work, pending_review?: pending_review, user: depositor) }
  let(:work_presenter) do
    WorkPresenter.new(work_form: WorkForm.new, work:, version_status: VersionStatus::NilStatus)
  end

  before do
    Current.user = viewer
  end

  after do
    Current.reset
  end

  context 'with work pending review and depositor viewing' do
    let(:pending_review) { true }

    it 'renders the alert' do
      render_inline(described_class.new(work_presenter:))

      expect(page).to have_css('.alert', text: 'Work successfully submitted for review')
    end
  end

  context 'with work pending review and non-depositor viewing' do
    let(:pending_review) { true }
    let(:viewer) { build(:user) }

    it 'does not render the alert' do
      render_inline(described_class.new(work_presenter:))

      expect(page).to have_no_css('.alert')
    end
  end

  context 'with work not pending review' do
    let(:pending_review) { false }

    it 'does not render the alert' do
      render_inline(described_class.new(work_presenter:))

      expect(page).to have_no_css('.alert')
    end
  end
end
