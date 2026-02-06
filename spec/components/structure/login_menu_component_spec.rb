# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Structure::LoginMenuComponent, type: :component do
  include Rails.application.routes.url_helpers

  before do
    allow(Current).to receive_messages(user:, groups: [])
  end

  context 'when user is connected to GitHub' do
    let(:user) { create(:user, :connected_to_github) }

    it 'shows the GitHub connection link' do
      render_inline(described_class.new)

      expect(page).to have_link('GitHub integration', href: user_github_path)
    end
  end

  context 'when user is depositor for a collection with GitHub deposit enabled' do
    let(:user) { create(:user) }

    before do
      create(:collection, github_deposit_enabled: true, depositors: [user])
    end

    it 'shows the GitHub connection link' do
      render_inline(described_class.new)

      expect(page).to have_link('GitHub integration', href: user_github_path)
    end
  end

  context 'when user is not connected to GitHub' do
    let(:user) { create(:user) }

    it 'does not show the GitHub connection link' do
      render_inline(described_class.new)

      expect(page).to have_no_link('GitHub integration')
    end
  end
end
