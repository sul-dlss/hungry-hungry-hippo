# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Tables::RowComponent, type: :component do
  context 'with values' do
    it 'renders the row' do
      render_inline(described_class.new(values: ['First value', 'Second value']))

      row = page.find('tr')
      expect(row).to have_css('td', count: 2)
      expect(row).to have_css('td', text: 'First value')
      expect(row).to have_css('td', text: 'Second value')
    end
  end

  context 'with cells' do
    it 'renders the row' do
      render_inline(described_class.new.tap do |component|
        component.with_cell { 'First cell' }
        component.with_cell { 'Second cell' }
      end)

      row = page.find('tr')
      expect(row).to have_css('td', count: 2)
      expect(row).to have_css('td', text: 'First cell')
      expect(row).to have_css('td', text: 'Second cell')
    end
  end
end
