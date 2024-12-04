# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::RepeatableNestedComponent, type: :component do
  subject(:component) do
    described_class.new(form:, field_name: :related_links, model_class: RelatedLinkForm,
                        form_component: RelatedLinks::EditComponent)
  end

  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:work_form) { WorkForm.new }

  it 'renders the nested component' do
    render_inline(component)
    expect(page).to have_text('Related links')
    expect(page).to have_field('Link text')
    expect(page).to have_field('URL')
  end
end
