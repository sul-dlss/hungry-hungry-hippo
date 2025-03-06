# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Tables::ListCellComponent, type: :component do
  context 'with item values' do
    it 'renders the cell' do
      render_inline(described_class.new(item_values: ['First value', 'Second value']))

      expect(page).to have_css('ul li', text: 'First value')
      expect(page).to have_css('ul li', text: 'Second value')
    end
  end

  context 'with items' do
    it 'renders the cell' do
      render_inline(described_class.new.tap do |component|
        component.with_item { 'First item' }
        component.with_item { 'Second item' }
      end)

      expect(page).to have_css('ul li', text: 'First item')
      expect(page).to have_css('ul li', text: 'Second item')
    end
  end
end
