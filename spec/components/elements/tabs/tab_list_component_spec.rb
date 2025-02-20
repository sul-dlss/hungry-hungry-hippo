# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Tabs::TabListComponent, type: :component do
  it 'renders tab list' do
    render_inline(described_class.new) do |component|
      component.with_tab(label: 'Tab 1', id: 'tab-1', pane_id: 'pane-1', active: true)
      component.with_tab(label: 'Tab 2', id: 'tab-2', pane_id: 'pane-2')
      component.with_header { '<h1>Header</h1>'.html_safe }
      component.with_pane(id: 'pane-1', tab_id: 'tab-1', active: true) { '<p>Content 1</p>'.html_safe }
      component.with_pane(id: 'pane-2', tab_id: 'tab-2') { '<p>Content 2</p>'.html_safe }
    end

    expect(page).to have_css(
      'ul.nav li.nav-item button.nav-link.active[id="tab-1"][data-bs-target="#pane-1"][aria-selected="true"]',
      text: 'Tab 1'
    )
    expect(page).to have_css(
      'button.nav-link[id="tab-2"][aria-selected="false"]:not(.active)',
      text: 'Tab 2'
    )
    expect(page).to have_css('h1', text: 'Header')

    expect(page).to have_css(
      'div.tab-content div.tab-pane.fade.show.active[id="pane-1"][aria-labelledby="tab-1"] p',
      text: 'Content 1'
    )

    expect(page).to have_css(
      'div.tab-pane.fade[id="pane-2"]:not(.show.active) p',
      text: 'Content 2'
    )
  end
end
