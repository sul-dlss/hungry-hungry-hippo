# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Tables::TreegridLeafRowComponent, type: :component do
  context 'when a label is provided' do
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

  context 'when label content is provided' do
    it 'renders the row with content' do
      render_inline(described_class.new(level: 2).tap do |component|
        component.with_cell { 'Cell 1' }
        component.with_label_content { 'My row content' }
      end)
      expect(page).to have_css('tr[role="row"][aria-level="2"][tabindex="0"][data-tree-role="leaf"]')
      expect(page).to have_css('td', count: 2)
      expect(page).to have_css('td[role="gridcell"][style="padding-left: 28px;"]', text: 'My row content')
      expect(page).to have_css('td', text: 'Cell 1')
    end
  end

  context 'when badge content is provided' do
    it 'renders the row with a badge content' do
      render_inline(described_class.new(level: 2, badge_content: 'New').tap do |component|
        component.with_cell { 'Cell 1' }
      end)
      expect(page).to have_css('tr[role="row"][aria-level="2"][tabindex="0"][data-tree-role="leaf"]')
      expect(page).to have_css('td', count: 2)
      expect(page).to have_css('td', text: 'Cell 1')
      expect(page).to have_css('span.badge', text: 'New')
    end
  end
end
