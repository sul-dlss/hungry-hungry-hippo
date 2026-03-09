# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::DepositingGithubComponent, type: :component do
  let(:component) { described_class.new(work_presenter:) }
  let(:work) { create(:github_repository) }
  let(:work_presenter) do
    WorkPresenter.new(work_form: WorkForm.new(github_deposit_enabled:), version_status:, work:)
  end
  let(:github_deposit_enabled) { true }
  let(:version_status) { build(:first_draft_version_status) }

  context 'when first draft version' do
    it 'renders the alert' do
      render_inline(component)

      expect(page).to have_css('.alert', text: 'One more step to complete deposit - ' \
                                               'Go to GitHub to create a release for this GitHub repository.')
      expect(page).to have_link('Go to GitHub', href: "https://github.com/#{work.github_repository_name}/releases")
    end
  end

  context 'when other version and accessioning' do
    let(:version_status) { build(:accessioning_version_status) }

    it 'does not render the alert' do
      expect(component.render?).to be false
    end
  end

  context 'when github deposit not enabled' do
    let(:github_deposit_enabled) { false }

    it 'does not render the alert' do
      expect(component.render?).to be false
    end
  end
end
