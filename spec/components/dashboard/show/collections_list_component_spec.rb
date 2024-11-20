# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::Show::CollectionsListComponent, type: :component do
  let!(:top_collection) { create(:collection, user:, druid: 'druid:ab234dd5678') }
  let!(:bottom_collection) { create(:collection, user:, druid: 'druid:bc234dd5678') }
  let(:user) { create(:user) }

  it 'renders the collections list for the user' do
    render_inline(described_class.new(label: 'Your collections', current_user: user))

    expect(page).to have_css('h3', text: 'Your collections')
    expect(page).to have_css('h4', text: top_collection.title)
    expect(page).to have_css('h4', text: bottom_collection.title)
  end
end
