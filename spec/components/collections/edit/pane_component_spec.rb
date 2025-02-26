# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::Edit::PaneComponent, type: :component do
  let(:component) do
    described_class.new(tab_name: :test_pane, label: 'Test Pane', active_tab_name:)
  end
  let(:active_tab_name) { :test_pane }

  context 'when no deposit button provided' do
    it 'renders the pane' do
      render_inline(component) { '<div>Test Pane Content</div>'.html_safe }
      tab_pane = page.find('div.tab-pane')
      expect(tab_pane).to have_css('.h4', text: 'Test Pane')
      expect(tab_pane).to have_css('div', text: 'Test Pane Content')
      expect(tab_pane).to have_button('Next')
      expect(tab_pane).to have_link('Cancel')
    end
  end

  context 'when deposit button provided' do
    it 'renders the pane' do
      render_inline(component.tap do |component|
        component.with_deposit_button { '<button>Deposit</button>'.html_safe }
      end) { '<div>Test Pane Content</div>'.html_safe }
      tab_pane = page.find('div.tab-pane')
      expect(tab_pane).to have_no_button('Next')
      expect(tab_pane).to have_link('Cancel')
      expect(tab_pane).to have_button('Deposit')
    end
  end

  context 'when this is active pane' do
    it 'renders the pane with active class' do
      render_inline(component) { '<div>Test Pane Content</div>'.html_safe }
      expect(page).to have_css('div.tab-pane.active')
    end
  end

  context 'when this is not active pane' do
    let(:active_tab_name) { :other_pane }

    it 'renders the pane without active class' do
      render_inline(component) { '<div>Test Pane Content</div>'.html_safe }
      expect(page).to have_css('div.tab-pane:not(.active)')
    end
  end
end
