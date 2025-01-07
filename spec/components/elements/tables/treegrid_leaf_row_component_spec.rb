# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Tables::TreegridLeafRowComponent, type: :component do
  it 'renders the row' do
    render_inline(described_class.new(level: 3, label: 'My row').tap do |component|
      component.with_cell { 'Cell 1' }
    end)
    expect(page).to have_css('tr[role="row"][aria-level="3"][tabindex="0"][data-tree-role="leaf"]')
    expect(page).to have_css('td', count: 2)
    expect(page).to have_css('td[role="gridcell"][style="padding-left: 48px;"]', text: 'My row')
    expect(page).to have_css('td', text: 'Cell 1')
  end
end
