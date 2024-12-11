# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Tables::TableComponent, type: :component do
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
                            classes: 'table table-striped').tap do |component|
                              component.with_header(headers: ['Header 1', 'Header 2'])
                              component.with_row(values: ['Row 1', 'Row 2'])
                            end
      )

      table = page.find('table#test-table')
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
          component.with_row(values: ['Row 1', 'Row 2'])
          component.with_row(values: ['Row 3', 'Row 4'])
        end
      )

      table = page.find('table#test-table')
      expect(table).to have_css('tbody')
      expect(table).to have_css('tr', count: 2)

      row1 = table.find('tr:nth-child(1)')
      expect(row1).to have_css('td', count: 2)
      expect(row1).to have_css('td', text: 'Row 1')
      expect(row1).to have_css('td', text: 'Row 2')

      row2 = table.find('tr:nth-child(2)')
      expect(row2).to have_css('td', count: 2)
      expect(row2).to have_css('td', text: 'Row 3')
      expect(row2).to have_css('td', text: 'Row 4')
    end
  end
end
