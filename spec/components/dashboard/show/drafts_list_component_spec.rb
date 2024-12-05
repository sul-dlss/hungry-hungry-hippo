# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::Show::DraftsListComponent, type: :component do
  let(:work) { create(:work, :with_druid, user:, collection:) }
  let(:collection) { create(:collection, :with_druid) }
  let(:user) { create(:user) }

  it 'renders the drafts list table with rows' do
    render_inline(described_class.new(works: [work]))

    table = page.find('table')
    expect(table).to have_css('th', text: 'Deposit')
    expect(table).to have_css('th', text: 'Collection')
    expect(table).to have_css('th', text: 'Last modified')
    table_body = table.find('tbody')
    expect(table_body).to have_css('tr', count: 1)
    row = table_body.find('tr')
    expect(row).to have_css('td:nth-of-type(1)', text: work.title)
    expect(row).to have_link(work.title, href: "/works/#{work.druid}")
    expect(row).to have_css('td:nth-of-type(2)', text: collection.title)
    expect(row).to have_link(collection.title, href: "/collections/#{collection.druid}")
  end
end
