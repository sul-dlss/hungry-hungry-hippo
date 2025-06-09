# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::RecentActivityListComponent, type: :component do
  context 'when rendering the recent activity list component with no items' do
    it 'renders the recent item activity list table with no rows' do
      render_inline(described_class.new(rows: [],
                                        label: 'Items',
                                        headers: [{ label: 'Item title' }, { label: 'Collection' }]))

      expect(page).to have_table('recent-activity-table')
      expect(page).to have_css('tbody tr', count: 0)
      expect(page).to have_content('No items activity for time period selected.')
    end
  end

  context 'when rendering the recent activity list component with works' do
    let(:work) { create(:work, :with_druid, user:, collection:, object_updated_at: Time.zone.now) }
    let(:work_without_druid) { create(:work, user:, collection:) }
    let(:collection) { create(:collection, :with_druid) }
    let(:user) { create(:user) }
    let(:rows) do
      [
        Admin::RecentActivityWorkPresenter.values_for(work:),
        Admin::RecentActivityWorkPresenter.values_for(work: work_without_druid)
      ]
    end

    it 'renders the recent item activity list table with rows of works' do
      render_inline(described_class.new(rows:,
                                        label: 'Items',
                                        headers: [{ label: 'Item title' }, { label: 'Collection' }]))

      table = page.find('table#recent-activity-table')
      table_body = table.find('tbody')
      expect(table_body).to have_css('tr', count: 2)
      first_row = table_body.find('tr:nth-of-type(1)')
      expect(first_row).to have_css('td:nth-of-type(1)', text: work.title)
      expect(first_row).to have_link(work.title, href: "/works/#{work.druid}")
      second_row = table_body.find('tr:nth-of-type(2)')
      expect(second_row).to have_css('td:nth-of-type(1)', text: work_without_druid.title)
      expect(second_row).to have_no_link(work_without_druid.title, href: "/works/#{work_without_druid.druid}")
    end
  end

  context 'when rendering the recent activity list component with collections' do
    let(:collection) { create(:collection, :with_druid) }
    let(:collection_without_druid) { create(:collection) }
    let(:rows) do
      [
        Admin::RecentActivityCollectionPresenter.values_for(collection:),
        Admin::RecentActivityCollectionPresenter.values_for(collection: collection_without_druid)
      ]
    end

    it 'renders the recent item activity list table with rows of works' do
      render_inline(described_class.new(rows:,
                                        label: 'Collections',
                                        headers: [{ label: 'Collections' }]))

      table = page.find('table#recent-activity-table')
      table_body = table.find('tbody')
      expect(table_body).to have_css('tr', count: 2)
      first_row = table_body.find('tr:nth-of-type(1)')
      expect(first_row).to have_css('td:nth-of-type(1)', text: collection.title)
      expect(first_row).to have_link(collection.title, href: "/collections/#{collection.druid}")
      second_row = table_body.find('tr:nth-of-type(2)')
      expect(second_row).to have_css('td:nth-of-type(1)', text: collection_without_druid.title)
      expect(second_row).to have_no_link(collection_without_druid.title, href: '/collection/')
    end
  end
end
