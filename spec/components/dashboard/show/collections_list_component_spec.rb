# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::Show::CollectionsListComponent, type: :component do
  let!(:top_collection) { create(:collection, user:, druid: 'druid:ab234dd5678') }
  let!(:bottom_collection) { create(:collection, user:, druid: 'druid:bc234dd5678') }
  let(:user) { create(:user) }
  let(:groups) { [] }

  before do
    allow(vc_test_controller).to receive(:current_user).and_return(user)
    Current.groups = groups
  end

  context 'when the user is not authorized to create collections' do
    it 'renders the collections list for the user' do
      render_inline(described_class.new(label: 'Your collections', collections: user.collections, status_map: {}))

      expect(page).to have_css('h3', text: 'Your collections')
      expect(page).to have_css('h4', text: top_collection.title)
      expect(page).to have_css('h4', text: bottom_collection.title)
      expect(page).to have_no_link(nil, href: '/collections/new')
    end
  end

  context 'when the user is authorized to create collections' do
    let(:groups) { [Settings.authorization_workgroup_names.administrators] }

    it 'renders the create a new collection button' do
      render_inline(described_class.new(label: 'Your collections', collections: user.collections, status_map: {}))

      expect(page).to have_link('Create a new collection', href: '/collections/new')
    end
  end
end
