# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::TableComponent, type: :component do
  it 'renders the table with rows' do
    render_inline(
      described_class.new(label: 'My title', id: 'test-table') do |component|
        component.with_row(label: 'First row', value: 'First value')
        component.with_row(label: 'Second row') { 'Second value' }
      end
    )
    within('table#test-table') do
      expect(page).to have_css('caption', text: 'My title')

      within('tbody') do
        expect(page).to have_css('tr', count: 2)

        within('tr:nth-child(1)') do
          expect(page).to have_css('th', text: 'First row')
          expect(page).to have_css('td', text: 'First value')
        end

        within('tr:nth-child(2)') do
          expect(page).to have_css('th', text: 'Second row')
          expect(page).to have_css('td', text: 'Second value')
        end
      end
    end
  end
end
