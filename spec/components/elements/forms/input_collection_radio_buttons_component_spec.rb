# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::InputCollectionRadioButtonsComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, test_form, vc_test_controller.view_context, {}) }
  let(:form_class) do
    Class.new(ApplicationForm) do
      attribute :work_type, :string
    end
  end
  let(:test_form) { form_class.new(work_type: 'Data') }

  it 'renders the collection radio buttons' do
    render_inline(described_class.new(form:, field_name: :work_type, input_collection: WorkType.all,
                                      text_method: :label,
                                      value_method: :label, div_classes: %w[col-3]))
    expect(page).to have_css('div.form-check.col-3', count: 9)
    expect(page).to have_field('work_type', type: 'radio', count: 9, class: 'form-check-input')
    expect(page).to have_checked_field('work_type', with: 'Data')
    expect(page).to have_css('label.form-check-label', count: 9)
    expect(page).to have_css('label.form-check-label', text: 'Data')
  end
end
