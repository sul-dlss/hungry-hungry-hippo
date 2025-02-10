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

  context 'with items' do
    it 'renders the row' do
      render_inline(described_class.new.tap do |component|
        component.with_item { 'First item' }
        component.with_item { 'Second item' }
      end)

      row = page.find('tr')
      expect(row).to have_css('td', count: 1)
      expect(row).to have_css('td ul li', text: 'First item')
      expect(row).to have_css('td ul li', text: 'Second item')
    end
  end

  context 'with label but no content' do
    it 'renders the row' do
      render_inline(described_class.new(label: 'My label'))

      row = page.find('tr')
      expect(row).to have_css('th', count: 1)
      expect(row).to have_css('td', count: 1)
      expect(row).to have_css('th', text: 'My label')
      expect(row).to have_css('td', text: '')
    end
  end
end
