# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::TabForm::TabListComponent, type: :component do
  include WorkMappingFixtures

  let(:work_form) { WorkForm.new }
  let(:hidden_fields) { %i[lock version collection_druid content_id] }

  context 'with no tabs' do
    it 'does not render the tabbed form' do
      render_inline(described_class.new(model: work_form, hidden_fields:))

      expect(page).to have_no_css('.tabbable-panes')
    end
  end

  context 'with tabs' do
    let(:component) { described_class.new(model: work_form, hidden_fields:) }
    let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }

    before do
      component.with_tab(label: 'Tab 1', tab_name: :tab_one, selected: true)
      component.with_tab(label: 'Tab 2', tab_name: :tab_two)
      component.with_pane(tab_name: :tab_one, label: 'Tab 1', form:, selected: true)
      component.with_pane(tab_name: :tab_two, label: 'Tab 2', form:)
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
