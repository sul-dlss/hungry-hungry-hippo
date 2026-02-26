# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::AbstractComponent, type: :component do
  include WorkMappingFixtures

  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_view_context, {}) }
  let(:work_form) { new_work_form_fixture }

  it 'renders the pane' do
    render_inline(described_class.new(form:))

    expect(page).to have_css('label', text: with_required_field_mark('Abstract'))
    expect(page).to have_field('Abstract', with: abstract_fixture)

    expect(page).to have_css('legend label', text: with_required_field_mark('Keywords (at least one is required)'))
    expect(page).to have_field('[keywords_attributes][0][text]', with: 'Biology')
  end

  context 'when abstract is not required' do
    it 'does not mark the abstract field as required' do
      render_inline(described_class.new(form:, mark_abstract_required: false))

      expect(page).to have_css('label', exact_text: 'Abstract')
    end
  end

  context 'when keywords is not required' do
    it 'does not mark the keywords field as required' do
      render_inline(described_class.new(form:, mark_keywords_required: false))

      expect(page).to have_css('legend label', exact_text: 'Keywords')
    end
  end
end
