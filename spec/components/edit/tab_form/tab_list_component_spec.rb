# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::TabForm::TabListComponent, type: :component do
  include WorkMappingFixtures

  let(:work_form) { WorkForm.new }
  let(:hidden_fields) { %i[lock version collection_druid content_id] }
  let(:form_id) { 'new_work' }
  let(:component) { described_class.new(model: work_form, hidden_fields:, form_id:) }
  let(:active_tab_name) { :tab_one }

  before do
    component.with_tab(label: 'Tab 1', tab_name: :tab_one, active_tab_name:)
    component.with_tab(label: 'Tab 2', tab_name: :tab_two, active_tab_name:)
    component.with_before_form_pane { '<div class="tab-pane">Tab 1</div>'.html_safe }
    component.with_pane { '<div class="tab-pane">Tab 2</div>'.html_safe }
  end

  it 'renders the tabbed form with tabs' do
    render_inline(component)
    expect(page).to have_css('.tabbable-panes')
    expect(page).to have_css('.nav-link', count: 2)
    expect(page).to have_css('.nav-link.active', text: 'Tab 1')
    expect(page).to have_css('.nav-link', text: 'Tab 2')
    expect(page).to have_css('.tab-pane', text: 'Tab 1')
    expect(page).to have_no_css('form .tab-pane', text: 'Tab 1')
    expect(page).to have_css('form .tab-pane', text: 'Tab 2')
  end
end
