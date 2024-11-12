# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::TableComponent, type: :component do
  it 'renders the table' do
    render_inline(described_class.new(id: 'test-table', classes: 'table table-striped', headers: nil))
    expect(page).to have_table('test-table')
  end

  context 'with headers' do
    it 'renders the table with headers' do
      render_inline(
        described_class.new(id: 'test-table', classes: 'table table-striped', headers: ['Header 1', 'Header 2'])
      )

      within('table#test-table') do
        expect(page).to have_css('thead')
        expect(page).to have_css('th', count: 2)
        expect(page).to have_css('th', text: 'Header 1')
        expect(page).to have_css('th', text: 'Header 2')
      end
    end
  end

  context 'with rows' do
    it 'renders the table with rows' do
      render_inline(
        described_class.new(id: 'test-table', classes: 'table table-striped',
                            headers: ['Header 1', 'Header 2']) do |component|
          component.with_row(['Row 1', 'Row 2'])
          component.with_row(['Row 3', 'Row 4'])
        end
      )

      within('table#test-table') do
        expect(page).to have_css('tbody')
        expect(page).to have_css('tr', count: 2)

        within('tr:nth-child(1)') do
          expect(page).to have_css('td', count: 2)
          expect(page).to have_css('td', text: 'Row 1')
          expect(page).to have_css('td', text: 'Row 2')
        end

        within('tr:nth-child(2)') do
          expect(page).to have_css('td', count: 2)
          expect(page).to have_css('td', text: 'Row 3')
          expect(page).to have_css('td', text: 'Row 4')
        end
      end
    end
  end
end
