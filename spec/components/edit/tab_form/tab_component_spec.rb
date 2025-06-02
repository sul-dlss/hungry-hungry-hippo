# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::TabForm::TabComponent, type: :component do
  context 'when this is the active tab' do
    it 'renders a tab' do
      render_inline(described_class.new(label: 'Tab 1', tab_name: :tab_one, active_tab_name: :tab_one))

      expect(page).to have_button('Tab 1', class: 'nav-link w-100 active')
    end
  end

  context 'when this is not the active tab' do
    it 'renders a tab without active class' do
      render_inline(described_class.new(label: 'Tab 1', tab_name: :tab_one, active_tab_name: :tab_two))

      expect(page).to have_button('Tab 1', class: 'nav-link w-100')
    end
  end
end
