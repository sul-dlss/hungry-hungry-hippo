# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::TitleComponent, type: :component do
  include WorkMappingFixtures

  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_view_context, {}) }
  let(:work_form) { new_work_form_fixture }

  context 'with a collection that has contact email' do
    it 'renders the pane' do
      render_inline(described_class.new(form:, work_form:))

      expect(page).to have_field('title', with: title_fixture)
      expect(page).to have_css('legend label', exact_text: 'Contact emails')
      expect(page).to have_field('Enter contact email', with: 'aperson@example.com')
      expect(page).to have_field('works_contact_email', type: 'hidden', with: works_contact_email_fixture)
    end
  end

  context 'with a collection that does not have contact email' do
    before do
      work_form.works_contact_email = nil
    end

    it 'renders the pane' do
      render_inline(described_class.new(form:, work_form:))

      expect(page).to have_css('legend label', exact_text: 'Contact emails (at least one is required)')
    end
  end
end
