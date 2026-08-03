# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::TabForm::TabListComponent, type: :component do
  let(:component) { described_class.new }
  let(:active_tab_name) { :tab_one }

  before do
    component.with_tab(label: 'Tab 1', tab_name: :tab_one, active_tab_name:)
    component.with_tab(label: 'Tab 2', tab_name: :tab_two, active_tab_name:)
    component.with_pane { 'Pane 1 content' }
    component.with_pane { 'Pane 2 content' }
  end

  it 'renders the tabbed navigation with tabs and panes' do
    render_inline(component)
    expect(page).to have_css('.tabbable-panes')
    expect(page).to have_css('.nav-link', count: 2)
    expect(page).to have_css('.nav-link.active', text: 'Tab 1')
    expect(page).to have_css('.nav-link', text: 'Tab 2')
    expect(page).to have_text('Pane 1 content')
    expect(page).to have_text('Pane 2 content')
  end
end
