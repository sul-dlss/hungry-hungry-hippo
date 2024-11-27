# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Layout::TabbedFormComponent, type: :component do
  context 'with no tabs' do
    it 'does not render the tabbed form' do
      render_inline(described_class.new)

      expect(page).to have_no_css('.tabbable-panes')
    end
  end
  
  context 'with tabs' do
    let(:component) { described_class.new }

    before do
      component.with_tab(label: 'Tab 1', tab_name: :tab_one, selected: true)
      component.with_tab(label: 'Tab 2', tab_name: :tab_two)
    end

    it 'renders the tabbed form with tabs' do
      render_inline(component)
      expect(page).to have_css('.tabbable-panes')
      expect(page).to have_css('.nav-link', count: 2)
      expect(page).to have_css('.nav-link', text: 'Tab 1')
      expect(page).to have_css('.nav-link', text: 'Tab 2')
    end
  end
end
