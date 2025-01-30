# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::TabForm::TabListComponent, type: :component do
  include WorkMappingFixtures

  let(:work_form) { WorkForm.new }
  let(:hidden_fields) { %i[lock version collection_druid content_id] }
  let(:form_id) { 'new_work' }
  let(:component) { described_class.new(model: work_form, hidden_fields:, form_id:) }

  before do
    component.with_tab(label: 'Tab 1', tab_name: :tab_one, selected: true)
    component.with_tab(label: 'Tab 2', tab_name: :tab_two)
    component.with_tab(label: 'Tab 3', tab_name: :tab_two)
    component.with_before_form_pane(tab_name: :tab_one, label: 'Tab 1', form_id:, selected: true)
    component.with_pane(tab_name: :tab_two, label: 'Tab 2', form_id:)
    component.with_pane(tab_name: :tab_three, label: 'Tab 3', form_id:)
  end

  it 'renders the tabbed form with tabs' do
    render_inline(component)
    expect(page).to have_css('.tabbable-panes')
    expect(page).to have_css('.nav-link', count: 3)
    expect(page).to have_css('.nav-link.active', text: 'Tab 1')
    expect(page).to have_css('.nav-link', text: 'Tab 2')
    expect(page).to have_css('.nav-link', text: 'Tab 3')
    expect(page).to have_css('.tab-pane', text: 'Tab 1')
    expect(page).to have_no_css('form .tab-pane', text: 'Tab 1')
    expect(page).to have_css('form .tab-pane', text: 'Tab 2')
    expect(page).to have_css('form .tab-pane', text: 'Tab 3')
  end
end
