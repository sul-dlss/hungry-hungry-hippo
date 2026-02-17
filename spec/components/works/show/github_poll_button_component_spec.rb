# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::GithubPollButtonComponent, type: :component do
  let(:work) { create(:github_repository, druid: druid_fixture) }
  let(:component) { described_class.new(work:) }

  context 'when the work is a GitHub repository with deposit enabled' do
    it 'renders the button' do
      render_inline(component)

      expect(page).to have_css("form[action='/github_repositories/#{druid_fixture}/poll'][method='post']")
      expect(page).to have_button('Check for new GitHub releases')
    end
  end

  context 'when the work is not a GitHub repository' do
    let(:work) { create(:work) }

    it 'does not render the button' do
      expect(component.render?).to be false
    end
  end

  context 'when the work is a GitHub repository but deposit is not enabled' do
    let(:work) { create(:github_repository, github_deposit_enabled: false) }

    it 'does not render the button' do
      expect(component.render?).to be false
    end
  end
end
