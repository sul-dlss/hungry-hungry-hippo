# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::HeaderLinkComponent, type: :component do
  let(:user) { create(:user) }

  context 'when collection has no druid' do
    let(:collection) { create(:collection, user:, druid: nil) }

    it 'renders the collections header without a link' do
      render_inline(described_class.new(collection:))

      expect(page).to have_css('h3.h4', text: collection.title)
      expect(page).to have_no_css('a')
    end
  end

  context 'when collection has a druid' do
    let(:collection) { create(:collection, user:, druid: 'druid:ab234dd5678') }

    it 'renders the collections header with a link' do
      render_inline(described_class.new(collection:))

      expect(page).to have_css('h3.h4', text: collection.title)
      expect(page).to have_css('a')
    end
  end
end
