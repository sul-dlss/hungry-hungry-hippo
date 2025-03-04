# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delete a Collection' do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }
  let(:cocina_object) do
    collection_with_metadata_fixture
  end
  let(:version_status) { build(:draft_version_status, version: cocina_object.version) }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Repository).to receive(:open_if_needed) { |args| args[:cocina_object] }
    sign_in(create(:user), groups: ['dlss:hydrus-app-administrators'])
  end

  context 'when the collection has no items' do
    let!(:collection) { create(:collection, druid:) }

    it 'deletes a collection' do
      visit collection_path(druid)

      expect(page).to have_css('h1', text: collection_title_fixture)
      click_link_or_button('Admin functions')
      click_link_or_button('Delete')

      check('I confirm this collection has been decommissioned in Argo ' \
            'and understand that this action cannot be undone.')
      click_link_or_button('Delete')

      expect(page).to have_css('h1', text: 'Dashboard')
      expect(page).to have_css('.alert', text: 'Collection successfully deleted.')
      expect(Collection.exists?(collection.id)).to be false
      expect(page).to have_current_path(dashboard_path)
    end
  end

  context 'when the collection has items' do
    let!(:collection) { create(:collection, druid:) }

    before do
      create(:work, collection:)
    end

    it 'deletes a collection' do
      visit collection_path(druid)

      expect(page).to have_css('h1', text: collection_title_fixture)
      click_link_or_button('Admin functions')
      click_link_or_button('Delete')

      expect(page).to have_css('h1', text: collection_title_fixture)
      expect(page).to have_css('.alert', text: 'Collection must be empty to delete.')
      expect(Collection.exists?(collection.id)).to be true
    end
  end
end
