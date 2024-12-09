# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::InputCollectionCheckboxesComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:form_class) do
    Class.new(ApplicationForm) do
      attribute :work_subtypes, array: true
    end
  end
  let(:work_form) { form_class.new(work_subtypes: ['Capstone']) }

  it 'renders the collection checkboxes' do
    render_inline(described_class.new(form:, field_name: :work_subtypes,
                                      input_collection: WorkType.subtypes_for('Text'),
                                      div_classes: %w[mt-2 mb-3]))
    expect(page).to have_css('div.form-check.mt-2.mb-3', count: 9)
    expect(page).to have_field('work_subtypes[]', type: 'checkbox', count: 9, class: 'form-check-input')
    expect(page).to have_checked_field('work_subtypes[]', with: 'Capstone')
    expect(page).to have_checked_field('work_subtypes[]', count: 1)
    expect(page).to have_css('label.form-check-label', count: 9)
    expect(page).to have_css('label.form-check-label', text: 'Capstone')
  end
end
