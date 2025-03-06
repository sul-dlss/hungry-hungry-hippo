# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::WorksListComponent, type: :component do
  let(:work) do
    create(:work, :with_druid, user:, collection:,
                               object_updated_at: Time.zone.parse('2024-12-3'))
  end
  let(:work_without_druid) { create(:work, user:, collection:) }
  let(:collection) { create(:collection, :with_druid) }
  let(:user) { create(:user) }
  let(:status_map) do
    {
      work.id => build(:first_draft_version_status),
      work_without_druid.id => VersionStatus::NilStatus.new
    }
  end

  it 'renders the works list table with rows' do
    render_inline(described_class.new(works: [work, work_without_druid], status_map:, id: 'my-works',
                                      label: 'My works'))

    table = page.find('table#my-works')
    expect(table).to have_css('caption', text: 'My works')
    expect(table).to have_css('th', text: 'Title')
    expect(table).to have_css('th', text: 'Collection')
    expect(table).to have_css('th', text: 'Deposit status')
    expect(table).to have_css('th', text: 'Druid')
    expect(table).to have_css('th', text: 'Last modified')
    table_body = table.find('tbody')
    expect(table_body).to have_css('tr', count: 2)
    first_row = table_body.find('tr:nth-of-type(1)')
    expect(first_row).to have_css('td:nth-of-type(1)', text: work.title)
    expect(first_row).to have_link(work.title, href: "/works/#{work.druid}") { |a|
      a['data-turbo-frame'] == '_top'
    }
    expect(first_row).to have_css('td:nth-of-type(2)', text: collection.title)
    expect(first_row).to have_link(collection.title, href: "/collections/#{collection.druid}") { |a|
      a['data-turbo-frame'] == '_top'
    }
    expect(first_row).to have_css('td:nth-of-type(3)', text: 'Draft - Not deposited')
    expect(first_row).to have_css('td:nth-of-type(4)', text: work.druid.delete_prefix('druid:'))
    expect(first_row).to have_css('td:nth-of-type(5)', text: 'Dec 03, 2024')
  end
end
