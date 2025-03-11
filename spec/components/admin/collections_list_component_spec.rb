# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::CollectionsListComponent, type: :component do
  let(:collection) { create(:collection, :with_druid, depositors: [user], managers: [user]) }
  let(:user) { create(:user) }

  it 'renders the works list table with rows' do
    render_inline(described_class.new(collections: [collection], user:, id: 'my-collections',
                                      label: 'My collections'))

    table = page.find('table#my-collections')
    expect(table).to have_css('caption', text: 'My collections')
    expect(table).to have_css('th', text: 'Collection')
    expect(table).to have_css('th', text: 'Druid')
    expect(table).to have_css('th', text: 'Roles')
    table_body = table.find('tbody')
    expect(table_body).to have_css('tr', count: 1)
    first_row = table_body.find('tr:nth-of-type(1)')
    expect(first_row).to have_css('td:nth-of-type(1)', text: collection.title)
    expect(first_row).to have_link(collection.title, href: "/collections/#{collection.druid}") { |a|
      a['data-turbo-frame'] == '_top'
    }
    expect(first_row).to have_css('td:nth-of-type(2)', text: collection.druid.delete_prefix('druid:'))
    expect(first_row).to have_css('td:nth-of-type(3)', text: 'Manager, Depositor')
  end
end
