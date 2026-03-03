# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::DepositingGithubComponent, type: :component do
  let(:work) { create(:github_repository) }
  let(:work_presenter) do
    WorkPresenter.new(work_form: WorkForm.new, version_status:, work:)
  end

  context 'when first draft version' do
    let(:version_status) { build(:first_draft_version_status) }

    it 'renders the alert' do
      render_inline(described_class.new(work_presenter:))

      expect(page).to have_css('.alert', text: 'One more step to complete deposit - ' \
                                               'Go to GitHub to create a release for this GitHub repository.')
    end
  end

  context 'when other version and accessioning' do
    let(:version_status) { build(:accessioning_version_status) }

    it 'does not render the alert' do
      render_inline(described_class.new(work_presenter:))

      expect(page).to have_no_css('.alert', text: 'One more step to complete deposit - ' \
                                                  'Go to GitHub to create a release for this GitHub repository.')
    end
  end
end
