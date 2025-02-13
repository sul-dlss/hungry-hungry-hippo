# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::Show::FirstUseAlertComponent, type: :component do
  let(:user) { create(:user) }

  context 'when first use' do
    before do
      create(:collection, depositors: [user])
    end

    it 'renders the alert' do
      render_inline(described_class.new(user:))

      expect(page).to have_css('.alert.alert-info', text: 'Congratulations on taking the first step')
      expect(page).to have_link('sdr-support@lists.stanford.edu', href: 'mailto:sdr-support@lists.stanford.edu')
    end
  end

  context 'when user is depositor for more than one collection' do
    before do
      create(:collection, depositors: [user])
      create(:collection, depositors: [user])
    end

    it 'does not render the alert' do
      render_inline(described_class.new(user:))

      expect(page).to have_no_css('.alert.alert-info')
    end
  end

  context 'when user has deposited' do
    before do
      collection = create(:collection, depositors: [user])
      create(:work, collection:, user:)
    end

    it 'does not render the alert' do
      render_inline(described_class.new(user:))

      expect(page).to have_no_css('.alert.alert-info')
    end
  end
end
