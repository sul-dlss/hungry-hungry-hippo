# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::AccessSettingsComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:work_form) { WorkForm.new(access: 'stanford') }
  let(:collection) { instance_double(Collection, depositor_selects_access?: depositor_selects) }

  context 'when the depositor selects access' do
    let(:depositor_selects) { true }

    it 'renders the select' do
      render_inline(described_class.new(form:, collection:))

      expect(page).to have_select('Who can download the files?', options: ['Stanford Community', 'Everyone'])
    end
  end

  context 'when the collection specifies access' do
    let(:depositor_selects) { false }

    it 'states the access and renders a hidden field' do
      render_inline(described_class.new(form:, collection:))

      expect(page).to have_text('The files in your deposit will be downloadable by the Stanford Community.')
      expect(page).to have_field('access', type: 'hidden', with: 'stanford')
    end
  end
end
