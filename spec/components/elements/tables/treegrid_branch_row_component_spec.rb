# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Tables::TreegridBranchRowComponent, type: :component do
  it 'renders the row' do
    render_inline(described_class.new(level: 3, label: 'My row', empty_cells: 2))
    expect(page).to have_css('tr[role="row"][aria-level="3"][tabindex="0"][data-tree-role="branch"]')
    expect(page).to have_css('td', count: 3)
    expect(page).to have_css('td[role="gridcell"][style="padding-left: 40px;"]', text: 'My row')
    expect(page).to have_css('td', text: '', count: 3)
  end
end
