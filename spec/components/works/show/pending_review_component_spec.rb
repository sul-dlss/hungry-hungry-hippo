# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::PendingReviewComponent, type: :component do
  let(:work) { instance_double(Work, pending_review?: pending_review) }
  let(:work_presenter) do
    WorkPresenter.new(work_form: WorkForm.new, work:, version_status: VersionStatus::NilStatus)
  end

  context 'with work pending review' do
    let(:pending_review) { true }

    it 'does not render the alert' do
      render_inline(described_class.new(work_presenter:))

      expect(page).to have_css('.alert', text: 'Work successfully submitted for review')
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
