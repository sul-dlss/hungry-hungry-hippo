# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::RecentActivityListComponent, type: :component do
  context 'when rendering the recent activity list component with works' do
    let(:work) { create(:work, :with_druid, user:, collection:, object_updated_at: Time.zone.now) }
    let(:work_without_druid) { create(:work, user:, collection:) }
    let(:collection) { create(:collection, :with_druid) }
    let(:user) { create(:user) }

    it 'renders the recent item activity list table with rows of works' do
      render_inline(described_class.new(items: [work, work_without_druid], label: 'Items', type: 'works'))

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

    it 'renders the recent item activity list table with rows of works' do
      render_inline(described_class.new(items: [collection, collection_without_druid],
                                        label: 'Collections',
                                        type: 'collections'))

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
