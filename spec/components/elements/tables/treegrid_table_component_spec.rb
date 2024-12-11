# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Tables::TreegridTableComponent, type: :component do
  context 'with no rows' do
    it 'does not render the table' do
      render_inline(described_class.new(id: 'test-table', label: 'Test Table'))

      expect(page).to have_no_table('test-table')
    end
  end

  context 'with headers' do
    it 'renders the table with headers' do
      render_inline(
        described_class.new(id: 'test-table', label: 'Test Table',
                            classes: 'table-another').tap do |component|
                              component.with_header(headers: ['Header 1', 'Header 2'])
                              component.with_row_branch(level: 1, label: 'Branch 1')
                            end
      )

      table = page.find('table.table-another.table-treegrid[role="treegrid"][aria-label="Test Table"]#test-table')
      expect(table).to have_css('caption', text: 'Test Table')
      expect(table).to have_css('thead')
      expect(table).to have_css('th', count: 2)
      expect(table).to have_css('th', text: 'Header 1')
      expect(table).to have_css('th', text: 'Header 2')
    end
  end

  context 'with rows' do
    it 'renders the table with rows' do
      render_inline(
        described_class.new(id: 'test-table', label: 'Test Table', classes: 'table table-striped').tap do |component|
          component.with_row_leaf(level: 1, label: 'Leaf 1')
          component.with_row_branch(level: 1, label: 'Branch 1')
          component.with_row_leaf(level: 2, label: 'Leaf 2')
        end
      )

      table = page.find('table#test-table')
      expect(table).to have_css('tbody')
      expect(table).to have_css('tr', count: 3)

      row1 = table.find('tr:nth-child(1)[aria-level="1"][data-tree-role="leaf"]')
      expect(row1).to have_css('td', count: 1)
      expect(row1).to have_css('td', text: 'Leaf 1')

      row2 = table.find('tr:nth-child(2)[aria-level="1"][data-tree-role="branch"]')
      expect(row2).to have_css('td', count: 1)
      expect(row2).to have_css('td', text: 'Branch 1')

      row3 = table.find('tr:nth-child(3)[aria-level="2"][data-tree-role="leaf"]')
      expect(row3).to have_css('td', count: 1)
      expect(row3).to have_css('td', text: 'Leaf 2')
    end
  end
end
