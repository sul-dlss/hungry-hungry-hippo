# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::ManageSharingButtonComponent, type: :component do
  let(:user) { create(:user) }
  let(:work) { create(:work, :with_druid, user:) }

  before do
    allow(Current).to receive(:groups).and_return([])
  end

  context 'when the user has permission to manage sharing' do
    before do
      allow(Current).to receive(:user).and_return(user)
    end

    it 'renders the manage sharing button' do
      render_inline(described_class.new(work:))

      expect(page).to have_link('Manage sharing', href: "/works/#{work.druid}/shares/new")
    end
  end

  context 'when the user does not have permission to manage sharing' do
    before do
      allow(Current).to receive(:user).and_return(create(:user))
    end

    it 'does not render the manage sharing button' do
      render_inline(described_class.new(work:))

      expect(page).to have_no_link('Manage sharing')
    end
  end
end
