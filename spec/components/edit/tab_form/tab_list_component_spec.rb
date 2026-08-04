# frozen_string_literal: true

require 'rails_helper'

# Anonymous ViewComponent classes can't compute a virtual_path, so these test doubles are named constants.
# Component for a test pane that just renders plain text.
class TabListComponentSpecPaneComponent < ViewComponent::Base
  def initialize(text)
    @text = text
    super()
  end

  def call
    @text.html_safe # rubocop:disable Rails/OutputSafety
  end
end

# Component for a test pane that reports whether it received the active_tab_name.
class TabListComponentSpecActiveTabAwarePaneComponent < ViewComponent::Base
  attr_accessor :active_tab_name

  def call
    "selected: #{active_tab_name == :tab_one}".html_safe # rubocop:disable Rails/OutputSafety
  end
end

RSpec.describe Edit::TabForm::TabListComponent, type: :component do
  let(:component) { described_class.new(active_tab_name: :tab_one) }
  let(:pane_one) { TabListComponentSpecPaneComponent.new('Pane 1 content') }
  let(:pane_two) { TabListComponentSpecPaneComponent.new('Pane 2 content') }

  before do
    component.with_tab(label: 'Tab 1', tab_name: :tab_one)
    component.with_tab(label: 'Tab 2', tab_name: :tab_two)
    component.with_pane(pane_one)
    component.with_pane(pane_two)
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

  context 'when a pane supports active_tab_name' do
    let(:pane_one) { TabListComponentSpecActiveTabAwarePaneComponent.new }

    it 'sets active_tab_name on the pane centrally, without it being passed at construction' do
      render_inline(component)
      expect(page).to have_text('selected: true')
    end
  end
end
